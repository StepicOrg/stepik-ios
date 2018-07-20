//
//  Downloader.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

fileprivate extension DownloaderSessionType {
    var configuration: URLSessionConfiguration {
        switch self {
        case .background(let id):
            let identifier = "downloader.\(id)"
            let config = URLSessionConfiguration.background(withIdentifier: identifier)
            config.isDiscretionary = true
            config.sessionSendsLaunchEvents = true
            return config
        case .foreground:
            return URLSessionConfiguration.default
        }
    }

    var description: String {
        switch self {
        case .background(let id):
            return "background(\(id))"
        case .foreground:
            return "foreground"
        }
    }
}

final class Downloader: RestorableBackgroundDownloaderProtocol {
    // Downloader class can't implement delegate protocols
    // cause it doesn't extend NSObject
    fileprivate final class Delegate: NSObject {
        var downloader: Downloader

        init(downloader: Downloader) {
            self.downloader = downloader
        }
    }

    // Store additional information for each download task
    fileprivate final class TaskInfo {
        let task: DownloaderTaskProtocol
        var urlSessionTask: URLSessionDownloadTask
        var state: DownloaderTaskState = .attached

        var expectedContentLength: Int64 = 0
        var downloadedContentLength: Int64 = 0

        var canBeRestarted = false
        var resumeDataAfterError: Data = Data(count: 0)

        init(task: DownloaderTaskProtocol, urlSessionTask: URLSessionDownloadTask) {
            self.task = task
            self.urlSessionTask = urlSessionTask
        }
    }

    // Cache sessions
    fileprivate final class Cache {
        private static let taskIDKey = "taskId"
        private static let urlTaskIDKey = "urlTaskId"
        private static let urlKey = "url"

        var downloader: Downloader

        init(downloader: Downloader) {
            self.downloader = downloader
        }
    }

    /// Semaphore wait delay
    private static let waitDelay = 20.0
    /// Mapping URLSession id -> TaskInfo
    private var tasks: [Int: TaskInfo] = [:]
    /// Mapping DownloaderTask id -> URLSession task id
    private var tasksMapping: [Int: Int] = [:]
    private var session: URLSession!

    /// Caches (nil when session is .foreground)
    private var cache: Cache?
    /// Mapping URLSession task id -> DownloaderTask
    private var restoredTasksMapping: [Int: DownloaderTaskProtocol] = [:]
    private var sessionInitSemaphore = DispatchSemaphore(value: 1)
    private var restoreTasksSemaphore = DispatchSemaphore(value: 1)
    /// URLSession tasks ids restored from previous background URLSession
    private var validRestoredTasksIDs: [Int] = []

    var restoredTasks: [DownloaderTaskProtocol] {
        return Array(self.restoredTasksMapping.values)
    }

    init(session: DownloaderSessionType) {
        NSLog("Downloader: created, session type = \(session.description)")
        // Acquire semaphore to synchronize with delegate methods
        self.sessionInitSemaphore.wait()

        let delegate = Delegate(downloader: self)

        self.session = URLSession(configuration: session.configuration,
                                  delegate: delegate,
                                  delegateQueue: nil)

        if case DownloaderSessionType.background(_) = session {
            cache = Cache(downloader: self)

            // Decrement here, increment in resumeRestoredTasks
            NSLog("Downloader: trying to restore tasks from previous background session with same ID...")
            restoreTasksSemaphore.wait()

            // Restore DownloaderTasks from cache
            restoreTasksFromCache()

            // Link DownloaderTasks with URLSessionTasks
            self.session.getAllTasks { tasks in
                defer {
                    self.sessionInitSemaphore.signal()
                    NSLog("Downloader: restored \(self.validRestoredTasksIDs.count) tasks from previous background session with same ID")
                }

                for task in tasks {
                    if let task = task as? URLSessionDownloadTask {
                        self.attachTaskAfterRestore(downloadTask: task)
                        self.validRestoredTasksIDs.append(task.taskIdentifier)
                    }
                }

                self.cache?.flush()
            }
        } else {
            // sessionInitSemaphore should be used only for background sessions
            sessionInitSemaphore.signal()
        }
    }

    private func resume(urlSessionTaskId: Int) throws {
        guard let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId) else {
            return
        }

        guard taskInfo.state == .attached ||
            taskInfo.state == .paused ||
            taskInfo.state == .stopped else {
                throw DownloaderError.incorrectState
        }

        // Re-init task with saved data
        // Or just resume current download
        if taskInfo.canBeRestarted {
            let resumeData = taskInfo.resumeDataAfterError
            let task = taskInfo.task

            removeTask(urlSessionTaskId: urlSessionTaskId)
            try add(task: task, resumeData: resumeData)
            // canBeRestarted == false now
            try resume(task: task)
        } else {
            taskInfo.state = .active
            taskInfo.task.stateReporter?(.active)
            taskInfo.urlSessionTask.resume()
        }
    }

    private func pause(urlSessionTaskId: Int) throws {
        guard let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId) else {
            return
        }

        guard taskInfo.state == .active else {
            throw DownloaderError.incorrectState
        }

        taskInfo.state = .paused
        taskInfo.task.stateReporter?(.paused)

        taskInfo.urlSessionTask.suspend()
    }

    private func cancel(urlSessionTaskId: Int) throws {
        guard let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId) else {
            return
        }

        guard taskInfo.state == .active ||
            taskInfo.state == .paused ||
            taskInfo.state == .attached else {
                throw DownloaderError.incorrectState
        }

        taskInfo.urlSessionTask.cancel()
    }

    private func reportOnCompletion(urlSessionTaskId: Int, location: URL) {
        guard let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId) else {
            return
        }

        taskInfo.task.completionReporter?(location)
        removeTask(urlSessionTaskId: urlSessionTaskId)
    }

    private func reportOnFailure(urlSessionTaskId: Int, error: Error) {
        getTaskInfo(urlSessionTaskId: urlSessionTaskId)?.task.failureReporter?(error)
    }

    private func reportProgress(urlSessionTaskId: Int) {
        guard let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId) else {
            return
        }

        let progress = Double(taskInfo.downloadedContentLength) / Double(taskInfo.expectedContentLength)

        if taskInfo.state != .active {
            // Report about .active only if state is changed (is it possible?)
            taskInfo.task.stateReporter?(.active)
        }
        taskInfo.state = .active

        if taskInfo.expectedContentLength == NSURLSessionTransferSizeUnknown {
            taskInfo.task.progressReporter?(nil)
        } else {
            taskInfo.task.progressReporter?(Float(progress))
        }
    }

    private func updateExpectedContentLength(urlSessionTaskId: Int, length: Int64) {
        getTaskInfo(urlSessionTaskId: urlSessionTaskId)?.expectedContentLength = length
    }

    private func updateDownloadedContentLength(urlSessionTaskId: Int, length: Int64) {
        getTaskInfo(urlSessionTaskId: urlSessionTaskId)?.downloadedContentLength = length
    }

    private func invalidateTask(urlSessionTaskId: Int) {
        guard let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId) else {
            return
        }

        taskInfo.state = .stopped
        taskInfo.task.stateReporter?(.stopped)
    }

    private func markAsCanBeRestarted(urlSessionTaskId: Int, buffer: Data?) {
        guard let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId) else {
            return
        }

        taskInfo.canBeRestarted = true
        taskInfo.resumeDataAfterError = buffer ?? Data(count: 0)
    }

    private func removeTask(urlSessionTaskId: Int) {
        guard let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId) else {
            return
        }

        taskInfo.state = .detached
        taskInfo.task.stateReporter?(.detached)

        tasksMapping.removeValue(forKey: taskInfo.task.id)
        tasks.removeValue(forKey: urlSessionTaskId)
        restoredTasksMapping.removeValue(forKey: urlSessionTaskId)

        cache?.flush()
    }

    private func getTaskInfo(urlSessionTaskId: Int) -> TaskInfo? {
        guard let taskInfo = tasks[urlSessionTaskId] else {
            NSLog("Downloader: trying to get info for detached task")
            return nil
        }

        return taskInfo
    }

    private func add(task: DownloaderTaskProtocol, resumeData: Data?) throws {
        if tasksMapping[task.id] != nil {
            throw DownloaderError.incorrectState
        }

        var urlSessionDownloadTask: URLSessionDownloadTask
        if let resumeData = resumeData {
            urlSessionDownloadTask = session.downloadTask(withResumeData: resumeData)
        } else {
            urlSessionDownloadTask = session.downloadTask(with: task.url)
        }
        urlSessionDownloadTask.priority = task.priority.rawValue

        let taskInfo = TaskInfo(task: task, urlSessionTask: urlSessionDownloadTask)
        assert(taskInfo.canBeRestarted == false)

        // If we have restored task with same id then task from
        // background attached session is invalid, so just remove it
        if restoredTasksMapping[urlSessionDownloadTask.taskIdentifier] != nil {
            invalidateRestoredTask(urlSessionTaskId: urlSessionDownloadTask.taskIdentifier)
        }

        tasksMapping[task.id] = urlSessionDownloadTask.taskIdentifier
        tasks[urlSessionDownloadTask.taskIdentifier] = taskInfo

        taskInfo.task.stateReporter?(.attached)
        cache?.flush()
    }

    private func getTaskState(urlSessionTaskId: Int) -> DownloaderTaskState? {
        return tasks[urlSessionTaskId]?.state
    }

    private func attachTaskAfterRestore(downloadTask: URLSessionDownloadTask) {
        NSLog("Downloader: restored url session tasks with id = \(downloadTask.taskIdentifier) from previous background session")
        guard let task = restoredTasksMapping[downloadTask.taskIdentifier] else {
            return
        }

        let taskInfo = TaskInfo(task: task, urlSessionTask: downloadTask)

        tasksMapping[task.id] = downloadTask.taskIdentifier
        tasks[downloadTask.taskIdentifier] = taskInfo

        taskInfo.state = .active
        taskInfo.task.stateReporter?(.active)
    }

    private func restoreTasksFromCache() {
        cache?.load().forEach { value in
            restoredTasksMapping[value.1] = value.0
        }
    }

    private func isRestoredTask(urlSessionTaskId: Int) -> Bool {
        return restoredTasksMapping[urlSessionTaskId] != nil
    }

    private func invalidateRestoredTask(urlSessionTaskId: Int) {
        guard let task = restoredTasksMapping[urlSessionTaskId] else {
            return
        }

        task.failureReporter?(RestorableBackgroundDownloaderError.invalidTask)
        task.stateReporter?(.detached)

        restoredTasksMapping.removeValue(forKey: urlSessionTaskId)
    }
}

extension Downloader {
    func add(task: DownloaderTaskProtocol) throws {
        try add(task: task, resumeData: nil)
    }

    func resume(task: DownloaderTaskProtocol) throws {
        guard let taskId = tasksMapping[task.id] else {
            throw DownloaderError.detachedState
        }

        try resume(urlSessionTaskId: taskId)
    }

    func pause(task: DownloaderTaskProtocol) throws {
        guard let taskId = tasksMapping[task.id] else {
            throw DownloaderError.detachedState
        }

        try pause(urlSessionTaskId: taskId)
    }

    func cancel(task: DownloaderTaskProtocol) throws {
        guard let taskId = tasksMapping[task.id] else {
            throw DownloaderError.detachedState
        }

        try cancel(urlSessionTaskId: taskId)
    }

    func getTaskState(for task: DownloaderTaskProtocol) -> DownloaderTaskState? {
        guard let taskId = tasksMapping[task.id] else {
            return nil
        }

        return getTaskState(urlSessionTaskId: taskId)
    }
}

extension Downloader.Delegate: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        NSLog("Downloader: received downloader delegate completion method for downloadTask = \(downloadTask.taskIdentifier), location = \(location)")
        let urlSessionTaskId = downloadTask.taskIdentifier

        _ = downloader.sessionInitSemaphore.wait(timeout: .now() + Downloader.waitDelay)
        downloader.sessionInitSemaphore.signal()

        if downloader.isRestoredTask(urlSessionTaskId: urlSessionTaskId) {
            downloader.restoreTasksSemaphore.wait()
            downloader.restoreTasksSemaphore.signal()
        }

        // Check for server-side errors
        if let response = downloadTask.response as? HTTPURLResponse {
            let statusCode = response.statusCode
            if !(200...299).contains(statusCode) {
                downloader.invalidateTask(urlSessionTaskId: urlSessionTaskId)
                downloader.reportOnFailure(urlSessionTaskId: urlSessionTaskId, error: DownloaderError.serverSide(statusCode: statusCode))
                return
            }
        }

        downloader.reportOnCompletion(urlSessionTaskId: urlSessionTaskId, location: location)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        NSLog("Downloader: received downloader delegate resume method for downloadTask = \(downloadTask.taskIdentifier)")
        _ = downloader.sessionInitSemaphore.wait(timeout: .now() + Downloader.waitDelay)
        downloader.sessionInitSemaphore.signal()

        let urlSessionTaskId = downloadTask.taskIdentifier

        if downloader.isRestoredTask(urlSessionTaskId: urlSessionTaskId) {
            downloader.restoreTasksSemaphore.wait()
            downloader.restoreTasksSemaphore.signal()
        }

        downloader.updateDownloadedContentLength(urlSessionTaskId: urlSessionTaskId, length: fileOffset)
        downloader.updateExpectedContentLength(urlSessionTaskId: urlSessionTaskId, length: expectedTotalBytes)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        _ = downloader.sessionInitSemaphore.wait(timeout: .now() + Downloader.waitDelay)
        downloader.sessionInitSemaphore.signal()

        let urlSessionTaskId = downloadTask.taskIdentifier

        if downloader.isRestoredTask(urlSessionTaskId: urlSessionTaskId) {
            downloader.restoreTasksSemaphore.wait()
            downloader.restoreTasksSemaphore.signal()
        }

        downloader.updateDownloadedContentLength(urlSessionTaskId: urlSessionTaskId, length: totalBytesWritten)
        downloader.updateExpectedContentLength(urlSessionTaskId: urlSessionTaskId, length: totalBytesExpectedToWrite)
        downloader.reportProgress(urlSessionTaskId: urlSessionTaskId)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        _ = downloader.sessionInitSemaphore.wait(timeout: .now() + Downloader.waitDelay)
        downloader.sessionInitSemaphore.signal()

        let urlSessionTaskId = task.taskIdentifier

        if downloader.isRestoredTask(urlSessionTaskId: urlSessionTaskId) {
            downloader.restoreTasksSemaphore.wait()
            downloader.restoreTasksSemaphore.signal()
        }

        guard let err = error as NSError? else {
            return
        }

        NSLog("Downloader: received downloader delegate error method for downloadTask = \(task.taskIdentifier)")
        downloader.invalidateTask(urlSessionTaskId: task.taskIdentifier)
        if err.code == NSURLErrorCancelled {
            downloader.removeTask(urlSessionTaskId: task.taskIdentifier)
        } else {
            let resumeData = err.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            downloader.reportOnFailure(urlSessionTaskId: task.taskIdentifier, error: DownloaderError.clientSide(error: err))
            downloader.markAsCanBeRestarted(urlSessionTaskId: task.taskIdentifier, buffer: resumeData)
        }
    }
}

extension Downloader.Cache {
    var key: String {
        return "downloaderCacheFor\(downloader.session.configuration.identifier ?? "")"
    }

    var defaults: UserDefaults {
        return UserDefaults.standard
    }

    func flush() {
        var data = [[String: Any]]()
        for (urlTaskID, taskInfo) in downloader.tasks {
            data.append([
                Downloader.Cache.taskIDKey: taskInfo.task.id,
                Downloader.Cache.urlTaskIDKey: urlTaskID,
                Downloader.Cache.urlKey: taskInfo.task.url.absoluteString
                ])
        }
        defaults.set(data, forKey: key)
        // Write on disk immediately to prevent cache losing
        defaults.synchronize()
    }

    func load() -> [(DownloaderTask, Int)] {
        var result = [(DownloaderTask, Int)]()
        for value in defaults.object(forKey: key) as? [[String: Any]] ?? [] {
            if let taskId = value[Downloader.Cache.taskIDKey] as? Int,
                let urlTaskId = value[Downloader.Cache.urlTaskIDKey] as? Int,
                let urlString = value[Downloader.Cache.urlKey] as? String,
                let url = URL(string: urlString) {
                result.append((DownloaderTask(id: taskId, url: url, executor: downloader, priority: .default), urlTaskId))
            }
        }
        return result
    }
}

extension Downloader {
    var id: String? {
        return session.configuration.identifier
    }

    func resumeRestoredTasks() {
        defer {
            restoreTasksSemaphore.signal()
            NSLog("Downloader: resumed restored downloaders tasks")
        }

        // Send cancel for all invalid tasks
        for (key, _) in restoredTasksMapping {
            if !validRestoredTasksIDs.contains(where: { $0 == key }) {
                invalidateRestoredTask(urlSessionTaskId: key)
            }
        }
    }
}
