import Foundation

typealias VideoDownloadingServiceEventHandler = (VideoDownloadingServiceEvent) -> Void

struct VideoDownloadingServiceEvent {
    var videoID: Video.IdType
    var state: State

    enum State {
        case active(progress: Float)
        case completed(storedURL: URL)
        case error(_ error: Error)
    }
}

protocol VideoDownloadingServiceProtocol: AnyObject {
    /// Subscribe on events about downloads
    func subscribeOnEvents(handler: @escaping VideoDownloadingServiceEventHandler)
    /// Download video
    func download(video: Video) throws
    /// Cancel active download
    func cancelDownload(videoID: Video.IdType) throws
    /// Get task progress
    func getTaskProgress(videoID: Video.IdType) throws -> Float?
    /// Get task state
    func getTaskState(videoID: Video.IdType) throws -> DownloaderTaskState?
    /// Check whether task exists
    func isTaskActive(videoID: Video.IdType) -> Bool
}

// FIXME: Inherit from `DownloadingServiceProtocol`
final class VideoDownloadingService: VideoDownloadingServiceProtocol {
    static let shared = VideoDownloadingService(
        downloader: Downloader(
            session: .background(id: VideoDownloadingService.sharedDownloaderSessionID)
        ),
        fileManager: VideoStoredFileManager(fileManager: FileManager.default),
        downloadVideoQualityStorageManager: DownloadVideoQualityStorageManager()
    )

    private static let sharedDownloaderSessionID = "video.main"

    private let downloader: RestorableBackgroundDownloaderProtocol
    private let fileManager: VideoStoredFileManagerProtocol
    private let downloadVideoQualityStorageManager: DownloadVideoQualityStorageManagerProtocol

    private var handlers: [VideoDownloadingServiceEventHandler] = []

    private struct MutableState {
        var observedTasks: [DownloaderTaskProtocol.IDType: DownloaderTaskProtocol] = [:]

        var videosForTasks: [DownloaderTaskProtocol.IDType: Video] = [:]
        var tasksForVideos: [Video.IdType: DownloaderTaskProtocol.IDType] = [:]
        var videoQuality: [Video.IdType: String] = [:]
        var tasksLastProgress: [DownloaderTaskProtocol.IDType: Float] = [:]
    }

    /// Protected `MutableState` value that provides thread-safe access to state values.
    @Protected
    private var mutableState = MutableState()

    init(
        downloader: RestorableBackgroundDownloaderProtocol,
        fileManager: VideoStoredFileManagerProtocol,
        downloadVideoQualityStorageManager: DownloadVideoQualityStorageManagerProtocol
    ) {
        self.downloader = downloader
        self.fileManager = fileManager
        self.downloadVideoQualityStorageManager = downloadVideoQualityStorageManager

        // FIXME: handle background downloads
        self.downloader.restoredTasks.forEach { task in
            print("video downloading service: cancel restored background task, id = \(task.id)")
            task.cancel()
        }
        self.downloader.resumeRestoredTasks()
    }

    // MARK: Public API

    func subscribeOnEvents(handler: @escaping VideoDownloadingServiceEventHandler) {
        self.handlers.append(handler)
    }

    func download(video: Video) throws {
        if self.$mutableState.read({ $0.tasksForVideos[video.id] }) != nil {
            throw Error.alreadyDownloading
        }

        let globalDownloadVideoQuality = self.downloadVideoQualityStorageManager.globalDownloadVideoQuality
        let nearestQuality = video.getNearestQualityToDefault(globalDownloadVideoQuality.uniqueIdentifier)

        guard let url = video.getUrlForQuality(nearestQuality) else {
            throw Error.videoURLNotFound
        }

        let task = DownloaderTask(url: url)

        self.setupReporters(for: task)

        task.start(with: self.downloader)

        self.$mutableState.write {
            $0.tasksForVideos[video.id] = task.id
            $0.videosForTasks[task.id] = video
            $0.videoQuality[video.id] = nearestQuality

            $0.observedTasks[task.id] = task
        }
    }

    func getTaskProgress(videoID: Video.IdType) throws -> Float? {
        guard let taskID = self.$mutableState.read({ $0.tasksForVideos[videoID] }) else {
            throw Error.videoNotFound
        }
        return self.getTaskProgressAndState(taskID: taskID)?.1
    }

    func getTaskState(videoID: Video.IdType) throws -> DownloaderTaskState? {
        guard let taskID = self.$mutableState.read({ $0.tasksForVideos[videoID] }) else {
            throw Error.videoNotFound
        }
        return self.getTaskProgressAndState(taskID: taskID)?.0
    }

    func cancelDownload(videoID: Video.IdType) throws {
        guard let taskID = self.$mutableState.read({ $0.tasksForVideos[videoID] }) else {
            throw Error.videoNotFound
        }

        guard let task = self.$mutableState.read({ $0.observedTasks[taskID] }) else {
            return
        }

        task.cancel()
    }

    func isTaskActive(videoID: Video.IdType) -> Bool {
        self.$mutableState.read({ $0.tasksForVideos.keys.contains(videoID) })
    }

    // MARK: Private API

    private func getTaskProgressAndState(taskID: DownloaderTaskProtocol.IDType) -> (DownloaderTaskState, Float)? {
        guard let progress = self.$mutableState.read({ $0.tasksLastProgress[taskID] }) else {
            return nil
        }

        guard let taskInfo = self.$mutableState.read({ $0.observedTasks[taskID] }) else {
            return nil
        }

        return (taskInfo.state, progress)
    }

    private func reportToSubscribers(event: VideoDownloadingServiceEvent) {
        self.handlers.forEach { handler in
            handler(event)
        }
    }

    private func setupReporters(for task: DownloaderTaskProtocol) {
        // Report progress
        task.progressReporter = { [weak self] progress in
            guard let strongSelf = self else {
                return
            }

            guard let video = strongSelf.$mutableState.read({ $0.videosForTasks[task.id] }) else {
                return
            }

            // Replace unknown progress by 0
            let lastProgress = strongSelf.$mutableState.read({ $0.tasksLastProgress[task.id] }) ?? 0
            let progress = max(lastProgress, progress ?? 0)

            let event = VideoDownloadingServiceEvent(
                videoID: video.id,
                state: .active(progress: progress)
            )

            strongSelf.$mutableState.write { $0.tasksLastProgress[task.id] = progress }
            strongSelf.reportToSubscribers(event: event)
        }

        // Report completion
        task.completionReporter = { [weak self] temporaryFileURL in
            guard let strongSelf = self,
                  let video = strongSelf.$mutableState.read({ $0.videosForTasks[task.id] }) else {
                return
            }

            let info = try? strongSelf.fileManager.saveTemporaryFileAsVideoFile(
                temporaryFileURL: temporaryFileURL,
                videoID: video.id
            )

            let state: VideoDownloadingServiceEvent.State = {
                if let url = info?.localURL {
                    return .completed(storedURL: url)
                } else {
                    return .error(Error.videoTemporaryFileNotSavedAsVideoFile)
                }
            }()

            let event = VideoDownloadingServiceEvent(
                videoID: video.id,
                state: state
            )

            if let videoQuality = strongSelf.$mutableState.read({ $0.videoQuality[video.id] }) {
                video.cachedQuality = videoQuality
                CoreDataHelper.shared.save()
            }

            strongSelf.reportToSubscribers(event: event)
            strongSelf.removeObservedTask(id: task.id)
        }

        // Failure reporter
        task.failureReporter = { [weak self] error in
            guard let strongSelf = self,
                  let video = strongSelf.$mutableState.read({ $0.videosForTasks[task.id] }) else {
                return
            }

            strongSelf.reportToSubscribers(
                event: VideoDownloadingServiceEvent(
                    videoID: video.id,
                    state: .error(error)
                )
            )
            strongSelf.removeObservedTask(id: task.id)
        }

        // State changed
        task.stateReporter = { [weak self] newState in
            if case .stopped = newState {
                guard let strongSelf = self,
                      let video = strongSelf.$mutableState.read({ $0.videosForTasks[task.id] }) else {
                    return
                }

                strongSelf.reportToSubscribers(
                    event: VideoDownloadingServiceEvent(
                        videoID: video.id,
                        state: .error(Error.videoDownloadingStopped)
                    )
                )
                strongSelf.removeObservedTask(id: task.id)
            }
        }
    }

    private func removeObservedTask(id: DownloaderTaskProtocol.IDType) {
        self.$mutableState.write {
            $0.observedTasks.removeValue(forKey: id)
            $0.tasksLastProgress.removeValue(forKey: id)

            if let video = $0.videosForTasks[id] {
                $0.tasksForVideos.removeValue(forKey: video.id)
                $0.videoQuality.removeValue(forKey: video.id)
            }

            $0.videosForTasks.removeValue(forKey: id)
        }
    }

    enum Error: Swift.Error {
        case videoNotFound
        case videoTemporaryFileNotSavedAsVideoFile
        case videoDownloadingStopped
        case videoURLNotFound
        case alreadyDownloading
    }
}
