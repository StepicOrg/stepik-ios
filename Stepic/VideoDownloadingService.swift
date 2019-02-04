//
//  VideoDownloadingService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

typealias VideoDownloadingServiceEventHandler = (VideoDownloadingServiceEvent) -> Void

struct VideoDownloadingServiceEvent {
    var videoID: Video.IdType
    var state: State

    enum State {
        case active(progress: Float)
        case completed(storedURL: URL)
        case error
    }
}

protocol VideoDownloadingServiceProtocol: class {
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

final class VideoDownloadingService: VideoDownloadingServiceProtocol {
    static let shared = VideoDownloadingService(
        downloader: Downloader(
            session: .background(id: VideoDownloadingService.sharedDownloaderSessionID)
        ),
        fileManager: VideoStoredFileManager(fileManager: FileManager.default)
    )

    private static let sharedDownloaderSessionID = "video.main"

    private let downloader: RestorableBackgroundDownloaderProtocol
    private let fileManager: VideoStoredFileManagerProtocol

    private var handlers: [VideoDownloadingServiceEventHandler] = []
    private var observedTasks: [DownloaderTaskProtocol.IDType: DownloaderTaskProtocol] = [:]

    private var videosForTasks: [DownloaderTaskProtocol.IDType: Video] = [:]
    private var tasksForVideos: [Video.IdType: DownloaderTaskProtocol.IDType] = [:]
    private var videoQuality: [Video.IdType: String] = [:]
    private var tasksLastProgress: [DownloaderTaskProtocol.IDType: Float] = [:]

    init(
        downloader: RestorableBackgroundDownloaderProtocol,
        fileManager: VideoStoredFileManagerProtocol
    ) {
        self.downloader = downloader
        self.fileManager = fileManager

        // FIXME: handle background downloads
        self.downloader.restoredTasks.forEach { task in
            print("video downloading service: cancel restored background task, id = \(task.id)")
            task.cancel()
        }
        self.downloader.resumeRestoredTasks()
    }

    // MARK: Public methods

    func subscribeOnEvents(handler: @escaping VideoDownloadingServiceEventHandler) {
        self.handlers.append(handler)
    }

    func download(video: Video) throws {
        if self.tasksForVideos[video.id] != nil {
            throw Error.alreadyDownloading
        }

        let nearestQuality = video.getNearestQualityToDefault(VideosInfo.downloadingVideoQuality)
        let url = video.getUrlForQuality(nearestQuality)
        let task = DownloaderTask(url: url)

        self.setupReporters(for: task)

        task.start(with: self.downloader)

        self.tasksForVideos[video.id] = task.id
        self.videosForTasks[task.id] = video
        self.videoQuality[video.id] = nearestQuality

        self.observedTasks[task.id] = task
    }

    func getTaskProgress(videoID: Video.IdType) throws -> Float? {
        guard let taskID = self.tasksForVideos[videoID] else {
            throw Error.videoNotFound
        }
        return self.getTaskProgressAndState(taskID: taskID)?.1
    }

    func getTaskState(videoID: Video.IdType) throws -> DownloaderTaskState? {
        guard let taskID = self.tasksForVideos[videoID] else {
            throw Error.videoNotFound
        }
        return self.getTaskProgressAndState(taskID: taskID)?.0
    }

    func cancelDownload(videoID: Video.IdType) throws {
        guard let taskID = self.tasksForVideos[videoID] else {
            throw Error.videoNotFound
        }

        guard let task = self.observedTasks[taskID] else {
            return
        }

        task.cancel()
    }

    func isTaskActive(videoID: Video.IdType) -> Bool {
        return self.tasksForVideos.keys.contains(videoID)
    }

    // MARK: Private methods

    private func getTaskProgressAndState(
        taskID: DownloaderTaskProtocol.IDType
    ) -> (DownloaderTaskState, Float)? {
        guard let progress = self.tasksLastProgress[taskID] else {
            return nil
        }

        guard let taskInfo = self.observedTasks[taskID] else {
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
            guard let video = self?.videosForTasks[task.id] else {
                return
            }

            // Replace unknown progress by 0
            let lastProgress = self?.tasksLastProgress[task.id] ?? 0
            let progress = max(lastProgress, progress ?? 0)

            let event = VideoDownloadingServiceEvent(
                videoID: video.id,
                state: .active(progress: progress)
            )

            self?.tasksLastProgress[task.id] = progress
            self?.reportToSubscribers(event: event)
        }

        // Report completion
        task.completionReporter = { [weak self] temporaryFileURL in
            guard let strongSelf = self,
                  let video = self?.videosForTasks[task.id] else {
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
                    return .error
                }
            }()

            let event = VideoDownloadingServiceEvent(
                videoID: video.id,
                state: state
            )

            if let videoQuality = self?.videoQuality[video.id] {
                video.cachedQuality = videoQuality
                CoreDataHelper.instance.save()
            }

            strongSelf.reportToSubscribers(event: event)
            strongSelf.removeObservedTask(id: task.id)
        }

        // Failure reporter
        task.failureReporter = { [weak self] error in
            guard let strongSelf = self,
                  let video = self?.videosForTasks[task.id] else {
                return
            }

            strongSelf.reportToSubscribers(
                event: VideoDownloadingServiceEvent(
                    videoID: video.id,
                    state: .error
                )
            )
            strongSelf.removeObservedTask(id: task.id)
        }

        // State changed
        task.stateReporter = { [weak self] newState in
            if case .stopped = newState {
                guard let video = self?.videosForTasks[task.id] else {
                    return
                }

                self?.reportToSubscribers(
                    event: VideoDownloadingServiceEvent(
                        videoID: video.id,
                        state: .error
                    )
                )
            }
        }
    }

    private func removeObservedTask(id: DownloaderTaskProtocol.IDType) {
        self.observedTasks.removeValue(forKey: id)
        self.tasksLastProgress.removeValue(forKey: id)

        if let video = self.videosForTasks[id] {
            self.tasksForVideos.removeValue(forKey: video.id)
            self.videoQuality.removeValue(forKey: video.id)
        }
        self.videosForTasks.removeValue(forKey: id)
    }

    enum Error: Swift.Error {
        case videoNotFound
        case alreadyDownloading
    }
}
