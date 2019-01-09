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
    var taskID: Int
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
    /// Download video; returns downloader task ID to use it for download control
    func download(videoID: Video.IdType, url: URL) -> DownloaderTaskProtocol.IDType
    /// Get downloader task by video id
    func getTaskID(by videoID: Video.IdType) -> DownloaderTaskProtocol.IDType?
    /// Get task progress and state
    func getTaskProgressAndState(
        taskID: DownloaderTaskProtocol.IDType
    ) -> (DownloaderTaskState, Float)?
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

    private var videosForTasks: [DownloaderTaskProtocol.IDType: Video.IdType] = [:]
    private var tasksForVideos: [Video.IdType: DownloaderTaskProtocol.IDType] = [:]

    private var tasksLastProgress: [DownloaderTaskProtocol.IDType: Float] = [:]

    init(
        downloader: RestorableBackgroundDownloaderProtocol,
        fileManager: VideoStoredFileManagerProtocol
    ) {
        self.downloader = downloader
        self.fileManager = fileManager

        // TODO: resume downloads
//        self.downloader.restoredTasks.forEach { task in
//
//        }
        self.downloader.resumeRestoredTasks()
    }

    // MARK: Public methods

    func subscribeOnEvents(handler: @escaping VideoDownloadingServiceEventHandler) {
        self.handlers.append(handler)
    }

    func download(videoID: Video.IdType, url: URL) -> DownloaderTaskProtocol.IDType {
        let task = DownloaderTask(url: url)
        self.setupReporters(for: task)

        task.start(with: self.downloader)

        self.tasksForVideos[videoID] = task.id
        self.videosForTasks[task.id] = videoID

        self.observedTasks[task.id] = task
        return task.id
    }

    func getTaskID(by videoID: Video.IdType) -> DownloaderTaskProtocol.IDType? {
        return self.tasksForVideos[videoID]
    }

    func getTaskProgressAndState(
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

    // MARK: Private methods

    private func reportToSubscribers(event: VideoDownloadingServiceEvent) {
        self.handlers.forEach { handler in
            handler(event)
        }
    }

    private func setupReporters(for task: DownloaderTaskProtocol) {
        // Report progress
        task.progressReporter = { [weak self] progress in
            // Replace unknown progress by 0
            let lastProgress = self?.tasksLastProgress[task.id] ?? 0
            let progress = max(lastProgress, progress ?? 0)

            let event = VideoDownloadingServiceEvent(
                taskID: task.id,
                state: .active(progress: progress)
            )

            self?.tasksLastProgress[task.id] = progress
            self?.reportToSubscribers(event: event)
        }

        // Report completion
        task.completionReporter = { [weak self] temporaryFileURL in
            guard let strongSelf = self,
                  let videoID = self?.videosForTasks[task.id] else {
                return
            }

            let info = try? strongSelf.fileManager.saveTemporaryFileAsVideoFile(
                temporaryFileURL: temporaryFileURL,
                videoID: videoID
            )

            let state: VideoDownloadingServiceEvent.State = {
                if let url = info?.localURL {
                    return .completed(storedURL: url)
                } else {
                    return .error
                }
            }()

            let event = VideoDownloadingServiceEvent(
                taskID: task.id,
                state: state
            )

            self?.reportToSubscribers(event: event)
            self?.removeObservedTask(id: task.id)
        }

        // Failure reporter
        task.failureReporter = { [weak self] error in
            self?.reportToSubscribers(
                event: VideoDownloadingServiceEvent(
                    taskID: task.id,
                    state: .error
                )
            )
            self?.removeObservedTask(id: task.id)
        }

        // State changed
        task.stateReporter = { [weak self] newState in
            if case .stopped = newState {
                self?.reportToSubscribers(
                    event: VideoDownloadingServiceEvent(
                        taskID: task.id,
                        state: .error
                    )
                )
            }
        }
    }

    private func removeObservedTask(id: DownloaderTaskProtocol.IDType) {
        self.observedTasks.removeValue(forKey: id)
        self.tasksLastProgress.removeValue(forKey: id)

        if let videoID = self.videosForTasks[id] {
            self.tasksForVideos.removeValue(forKey: videoID)
        }
        self.videosForTasks.removeValue(forKey: id)
    }
}
