import Foundation

typealias DownloadingServiceEventHandler = (DownloadingServiceEvent) -> Void

struct DownloadingServiceEvent {
    var taskID: DownloaderTaskProtocol.IDType
    var state: State

    enum State {
        case active(progress: Float)
        case completed(storedURL: URL)
        case error(_ error: Error)
    }
}

protocol DownloadingServiceProtocol: AnyObject {
    /// Subscribe on events about downloads
    func subscribeOnEvents(handler: @escaping DownloadingServiceEventHandler)
    /// Download data by URL and once a download request has successfully completed moves the temporary file.
    func download(url: URL, destinationFileName: String) throws -> DownloaderTaskProtocol.IDType
    /// Cancel active download by id
    func cancelDownload(taskID: DownloaderTaskProtocol.IDType) throws
    /// Get task progress by id
    func getTaskProgress(taskID: DownloaderTaskProtocol.IDType) -> Float?
    /// Get task state by id
    func getTaskState(taskID: DownloaderTaskProtocol.IDType) -> DownloaderTaskState?
    /// Check whether task exists
    func isTaskActive(taskID: DownloaderTaskProtocol.IDType) -> Bool
}

final class DownloadingService: DownloadingServiceProtocol {
    private let downloader: RestorableBackgroundDownloaderProtocol
    private let fileManager: StoredFileManagerProtocol

    private var handlers: [DownloadingServiceEventHandler] = []
    private var observedTasks: [DownloaderTaskProtocol.IDType: DownloaderTaskProtocol] = [:]

    private var taskIDByURL: [URL: DownloaderTaskProtocol.IDType] = [:]
    private var taskProgressByID: [DownloaderTaskProtocol.IDType: Float] = [:]
    private var destinationFileNameByID: [DownloaderTaskProtocol.IDType: String] = [:]

    init(
        downloader: RestorableBackgroundDownloaderProtocol,
        fileManager: StoredFileManagerProtocol
    ) {
        self.downloader = downloader
        self.fileManager = fileManager

        // FIXME: handle background downloads
        self.downloader.restoredTasks.forEach { task in
            print("downloading service: cancel restored background task, id = \(task.id)")
            task.cancel()
        }
        self.downloader.resumeRestoredTasks()
    }

    // MARK: Public API

    func subscribeOnEvents(handler: @escaping DownloadingServiceEventHandler) {
        self.handlers.append(handler)
    }

    func download(url: URL, destinationFileName: String) throws -> DownloaderTaskProtocol.IDType {
        if self.taskIDByURL[url] != nil {
            throw Error.alreadyDownloading
        }

        let task = DownloaderTask(url: url)
        self.setupReporters(for: task)
        task.start(with: self.downloader)

        self.taskIDByURL[url] = task.id
        self.destinationFileNameByID[task.id] = destinationFileName
        self.observedTasks[task.id] = task

        return task.id
    }

    func cancelDownload(taskID: DownloaderTaskProtocol.IDType) throws {
        guard let task = self.observedTasks[taskID] else {
            throw Error.taskNotFound
        }

        task.cancel()
    }

    func getTaskProgress(taskID: DownloaderTaskProtocol.IDType) -> Float? {
        self.getTaskProgressAndState(taskID: taskID)?.1
    }

    func getTaskState(taskID: DownloaderTaskProtocol.IDType) -> DownloaderTaskState? {
        self.getTaskProgressAndState(taskID: taskID)?.0
    }

    func isTaskActive(taskID: DownloaderTaskProtocol.IDType) -> Bool {
        self.observedTasks.keys.contains(taskID)
    }

    // MARK: Private API

    private func getTaskProgressAndState(taskID: DownloaderTaskProtocol.IDType) -> (DownloaderTaskState, Float)? {
        guard let progress = self.taskProgressByID[taskID] else {
            return nil
        }

        guard let taskInfo = self.observedTasks[taskID] else {
            return nil
        }

        return (taskInfo.state, progress)
    }

    private func reportToSubscribers(event: DownloadingServiceEvent) {
        self.handlers.forEach { handler in
            handler(event)
        }
    }

    private func setupReporters(for task: DownloaderTaskProtocol) {
        let taskID = task.id

        // Report progress
        task.progressReporter = { [weak self] progress in
            guard let strongSelf = self else {
                return
            }

            // Replace unknown progress by 0
            let lastProgress = strongSelf.taskProgressByID[taskID] ?? 0
            let progress = max(lastProgress, progress ?? 0)

            let event = DownloadingServiceEvent(taskID: taskID, state: .active(progress: progress))

            strongSelf.taskProgressByID[taskID] = progress
            strongSelf.reportToSubscribers(event: event)
        }

        // Report completion
        task.completionReporter = { [weak self] temporaryFileURL in
            guard let strongSelf = self,
                  let destinationFileName = strongSelf.destinationFileNameByID[taskID] else {
                return
            }

            let storedFileInfo = try? strongSelf.fileManager.moveStoredFile(
                from: temporaryFileURL,
                destinationFileName: destinationFileName
            )

            let state: DownloadingServiceEvent.State = {
                if let localURL = storedFileInfo?.localURL {
                    return .completed(storedURL: localURL)
                } else {
                    return .error(Error.temporaryFileNotSavedAsPermanentFile)
                }
            }()

            let event = DownloadingServiceEvent(taskID: taskID, state: state)

            strongSelf.reportToSubscribers(event: event)
            strongSelf.removeObservedTask(id: taskID)
        }

        // Failure reporter
        task.failureReporter = { [weak self] error in
            guard let strongSelf = self else {
                return
            }

            let event = DownloadingServiceEvent(taskID: taskID, state: .error(error))

            strongSelf.reportToSubscribers(event: event)
            strongSelf.removeObservedTask(id: taskID)
        }

        // State changed
        task.stateReporter = { [weak self] newState in
            if case .stopped = newState {
                guard let strongSelf = self else {
                    return
                }

                let event = DownloadingServiceEvent(taskID: taskID, state: .error(Error.downloadingStopped))

                strongSelf.reportToSubscribers(event: event)
                strongSelf.removeObservedTask(id: taskID)
            }
        }
    }

    private func removeObservedTask(id: DownloaderTaskProtocol.IDType) {
        self.observedTasks.removeValue(forKey: id)
        self.taskProgressByID.removeValue(forKey: id)
        self.destinationFileNameByID.removeValue(forKey: id)

        if let taskURL = self.taskIDByURL.first(where: { $1 == id })?.key {
            self.taskIDByURL.removeValue(forKey: taskURL)
        }
    }

    enum Error: Swift.Error {
        case taskNotFound
        case alreadyDownloading
        case downloadingStopped
        case temporaryFileNotSavedAsPermanentFile
    }
}
