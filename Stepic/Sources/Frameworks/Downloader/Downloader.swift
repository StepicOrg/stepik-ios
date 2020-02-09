import Foundation

// MARK: DownloaderSessionType (Spec) -

fileprivate extension DownloaderSessionType {
    var configuration: URLSessionConfiguration {
        switch self {
        case .background(let id):
            let identifier = "downloader.\(id)"
            let config = URLSessionConfiguration.background(withIdentifier: identifier)
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

// MARK: - Downloader: RestorableBackgroundDownloaderProtocol -

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
        var resumeDataAfterError = Data(count: 0)

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
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var session: URLSession!

    /// Caches (nil when session is .foreground)
    private var cache: Cache?
    /// Mapping URLSession task id -> DownloaderTask
    private var restoredTasksMapping: [Int: DownloaderTaskProtocol] = [:]
    private var sessionInitSemaphore = DispatchSemaphore(value: 1)
    private var restoreTasksSemaphore = DispatchSemaphore(value: 1)
    /// URLSession tasks ids restored from previous background URLSession
    private var validRestoredTasksIDs: [Int] = []
    /// Synchronization mutex
    private var mutex = pthread_mutex_t()

    init(session: DownloaderSessionType) {
        NSLog("Downloader: created, session type = \(session.description)")
        // Acquire semaphore to synchronize with delegate methods
        self.sessionInitSemaphore.wait()

        let delegate = Delegate(downloader: self)
        self.session = URLSession(configuration: session.configuration, delegate: delegate, delegateQueue: nil)

        // Initialize mutex attributes
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        // Initialize mutex
        pthread_mutex_init(&self.mutex, &attr)
        pthread_mutexattr_destroy(&attr)

        if case .background(_) = session {
            self.cache = Cache(downloader: self)

            // Decrement here, increment in resumeRestoredTasks
            NSLog("Downloader: trying to restore tasks from previous background session with same ID...")
            self.restoreTasksSemaphore.wait()

            // Restore DownloaderTasks from cache
            self.restoreTasksFromCache()

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
            self.sessionInitSemaphore.signal()
        }
    }

    deinit {
        assert(
            pthread_mutex_trylock(&self.mutex) == 0 && pthread_mutex_unlock(&self.mutex) == 0,
            "deinitialization of a locked mutex results in undefined behavior!"
        )
        pthread_mutex_destroy(&self.mutex)
    }

    // MARK: Private API (DownloaderProtocol)

    private func resume(urlSessionTaskID: Int) throws {
        guard let taskInfo = self.getTaskInfo(urlSessionTaskID: urlSessionTaskID) else {
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

            self.removeTask(urlSessionTaskID: urlSessionTaskID)
            try self.add(task: task, resumeData: resumeData)
            // canBeRestarted == false now
            try self.resume(task: task)
        } else {
            taskInfo.state = .active
            taskInfo.task.stateReporter?(.active)
            taskInfo.urlSessionTask.resume()
        }
    }

    private func pause(urlSessionTaskID: Int) throws {
        guard let taskInfo = self.getTaskInfo(urlSessionTaskID: urlSessionTaskID) else {
            return
        }

        guard taskInfo.state == .active else {
            throw DownloaderError.incorrectState
        }

        taskInfo.state = .paused
        taskInfo.task.stateReporter?(.paused)

        taskInfo.urlSessionTask.suspend()
    }

    private func cancel(urlSessionTaskID: Int) throws {
        guard let taskInfo = self.getTaskInfo(urlSessionTaskID: urlSessionTaskID) else {
            return
        }

        guard taskInfo.state == .active ||
              taskInfo.state == .paused ||
              taskInfo.state == .attached else {
            throw DownloaderError.incorrectState
        }

        taskInfo.urlSessionTask.cancel()
    }

    private func reportOnCompletion(urlSessionTaskID: Int, location: URL) {
        guard let taskInfo = self.getTaskInfo(urlSessionTaskID: urlSessionTaskID) else {
            return
        }

        taskInfo.task.completionReporter?(location)
        self.removeTask(urlSessionTaskID: urlSessionTaskID)
    }

    private func reportOnFailure(urlSessionTaskID: Int, error: Error) {
        self.getTaskInfo(urlSessionTaskID: urlSessionTaskID)?.task.failureReporter?(error)
    }

    private func reportProgress(urlSessionTaskID: Int) {
        guard let taskInfo = getTaskInfo(urlSessionTaskID: urlSessionTaskID) else {
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

    private func updateExpectedContentLength(urlSessionTaskID: Int, length: Int64) {
        self.getTaskInfo(urlSessionTaskID: urlSessionTaskID)?.expectedContentLength = length
    }

    private func updateDownloadedContentLength(urlSessionTaskID: Int, length: Int64) {
        self.getTaskInfo(urlSessionTaskID: urlSessionTaskID)?.downloadedContentLength = length
    }

    private func invalidateTask(urlSessionTaskID: Int) {
        guard let taskInfo = self.getTaskInfo(urlSessionTaskID: urlSessionTaskID) else {
            return
        }

        taskInfo.state = .stopped
        taskInfo.task.stateReporter?(.stopped)
    }

    private func markAsCanBeRestarted(urlSessionTaskID: Int, buffer: Data?) {
        guard let taskInfo = self.getTaskInfo(urlSessionTaskID: urlSessionTaskID) else {
            return
        }

        taskInfo.canBeRestarted = true
        taskInfo.resumeDataAfterError = buffer ?? Data(count: 0)
    }

    private func removeTask(urlSessionTaskID: Int) {
        guard let taskInfo = self.getTaskInfo(urlSessionTaskID: urlSessionTaskID) else {
            return
        }

        taskInfo.state = .detached
        taskInfo.task.stateReporter?(.detached)

        self.tasksMapping.removeValue(forKey: taskInfo.task.id)
        self.tasks.removeValue(forKey: urlSessionTaskID)
        self.restoredTasksMapping.removeValue(forKey: urlSessionTaskID)

        self.cache?.flush()
    }

    private func getTaskInfo(urlSessionTaskID: Int) -> TaskInfo? {
        pthread_mutex_lock(&self.mutex)
        defer { pthread_mutex_unlock(&self.mutex) }

        guard let taskInfo = self.tasks[urlSessionTaskID] else {
            NSLog("Downloader: trying to get info for detached task")
            return nil
        }

        return taskInfo
    }

    private func add(task: DownloaderTaskProtocol, resumeData: Data?) throws {
        if self.tasksMapping[task.id] != nil {
            throw DownloaderError.incorrectState
        }

        var urlSessionDownloadTask: URLSessionDownloadTask
        if let resumeData = resumeData {
            urlSessionDownloadTask = self.session.downloadTask(withResumeData: resumeData)
        } else {
            urlSessionDownloadTask = self.session.downloadTask(with: task.url)
        }
        urlSessionDownloadTask.priority = task.priority.rawValue

        let taskInfo = TaskInfo(task: task, urlSessionTask: urlSessionDownloadTask)
        assert(taskInfo.canBeRestarted == false)

        // If we have restored task with same id then task from
        // background attached session is invalid, so just remove it
        if self.restoredTasksMapping[urlSessionDownloadTask.taskIdentifier] != nil {
            self.invalidateRestoredTask(urlSessionTaskID: urlSessionDownloadTask.taskIdentifier)
        }

        self.tasksMapping[task.id] = urlSessionDownloadTask.taskIdentifier
        self.tasks[urlSessionDownloadTask.taskIdentifier] = taskInfo

        taskInfo.task.stateReporter?(.attached)
        self.cache?.flush()
    }

    private func getTaskState(urlSessionTaskID: Int) -> DownloaderTaskState? {
        self.tasks[urlSessionTaskID]?.state
    }

    private func attachTaskAfterRestore(downloadTask: URLSessionDownloadTask) {
        NSLog("Downloader: restored url session tasks with id = \(downloadTask.taskIdentifier) from previous background session")
        guard let task = self.restoredTasksMapping[downloadTask.taskIdentifier] else {
            return
        }

        let taskInfo = TaskInfo(task: task, urlSessionTask: downloadTask)

        self.tasksMapping[task.id] = downloadTask.taskIdentifier
        self.tasks[downloadTask.taskIdentifier] = taskInfo

        taskInfo.state = .active
        taskInfo.task.stateReporter?(.active)
    }

    private func restoreTasksFromCache() {
        self.cache?.load().forEach { value in
            self.restoredTasksMapping[value.1] = value.0
        }
    }

    private func isRestoredTask(urlSessionTaskID: Int) -> Bool {
        self.restoredTasksMapping[urlSessionTaskID] != nil
    }

    private func invalidateRestoredTask(urlSessionTaskID: Int) {
        guard let task = self.restoredTasksMapping[urlSessionTaskID] else {
            return
        }

        task.failureReporter?(RestorableBackgroundDownloaderError.invalidTask)
        task.stateReporter?(.detached)

        self.restoredTasksMapping.removeValue(forKey: urlSessionTaskID)
    }
}

// MARK: - Downloader (DownloaderProtocol) -

extension Downloader {
    func add(task: DownloaderTaskProtocol) throws {
        pthread_mutex_lock(&self.mutex)
        defer { pthread_mutex_unlock(&self.mutex) }
        try self.add(task: task, resumeData: nil)
    }

    func resume(task: DownloaderTaskProtocol) throws {
        pthread_mutex_lock(&self.mutex)
        defer { pthread_mutex_unlock(&self.mutex) }

        guard let taskID = self.tasksMapping[task.id] else {
            throw DownloaderError.detachedState
        }

        try self.resume(urlSessionTaskID: taskID)
    }

    func pause(task: DownloaderTaskProtocol) throws {
        pthread_mutex_lock(&self.mutex)
        defer { pthread_mutex_unlock(&self.mutex) }

        guard let taskID = self.tasksMapping[task.id] else {
            throw DownloaderError.detachedState
        }

        try self.pause(urlSessionTaskID: taskID)
    }

    func cancel(task: DownloaderTaskProtocol) throws {
        pthread_mutex_lock(&self.mutex)
        defer { pthread_mutex_unlock(&self.mutex) }

        guard let taskID = self.tasksMapping[task.id] else {
            throw DownloaderError.detachedState
        }

        try self.cancel(urlSessionTaskID: taskID)
    }

    func getTaskState(for task: DownloaderTaskProtocol) -> DownloaderTaskState? {
        pthread_mutex_lock(&self.mutex)
        defer { pthread_mutex_unlock(&self.mutex) }

        guard let taskID = self.tasksMapping[task.id] else {
            return nil
        }

        return self.getTaskState(urlSessionTaskID: taskID)
    }
}

// MARK: - Downloader.Delegate: URLSessionDownloadDelegate -

extension Downloader.Delegate: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        NSLog("Downloader: received downloader delegate completion method for downloadTask = \(downloadTask.taskIdentifier), location = \(location)")
        let urlSessionTaskID = downloadTask.taskIdentifier

        _ = self.downloader.sessionInitSemaphore.wait(timeout: .now() + Downloader.waitDelay)
        self.downloader.sessionInitSemaphore.signal()

        if self.downloader.isRestoredTask(urlSessionTaskID: urlSessionTaskID) {
            self.downloader.restoreTasksSemaphore.wait()
            self.downloader.restoreTasksSemaphore.signal()
        }

        // Check for server-side errors
        if let response = downloadTask.response as? HTTPURLResponse {
            let statusCode = response.statusCode
            if !(200...299).contains(statusCode) {
                self.downloader.invalidateTask(urlSessionTaskID: urlSessionTaskID)
                self.downloader.reportOnFailure(
                    urlSessionTaskID: urlSessionTaskID,
                    error: DownloaderError.serverSide(statusCode: statusCode)
                )
                return
            }
        }

        self.downloader.reportOnCompletion(urlSessionTaskID: urlSessionTaskID, location: location)
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64
    ) {
        NSLog("Downloader: received downloader delegate resume method for downloadTask = \(downloadTask.taskIdentifier)")
        _ = self.downloader.sessionInitSemaphore.wait(timeout: .now() + Downloader.waitDelay)
        self.downloader.sessionInitSemaphore.signal()

        let urlSessionTaskID = downloadTask.taskIdentifier

        if self.downloader.isRestoredTask(urlSessionTaskID: urlSessionTaskID) {
            self.downloader.restoreTasksSemaphore.wait()
            self.downloader.restoreTasksSemaphore.signal()
        }

        self.downloader.updateDownloadedContentLength(urlSessionTaskID: urlSessionTaskID, length: fileOffset)
        self.downloader.updateExpectedContentLength(urlSessionTaskID: urlSessionTaskID, length: expectedTotalBytes)
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        _ = self.downloader.sessionInitSemaphore.wait(timeout: .now() + Downloader.waitDelay)
        self.downloader.sessionInitSemaphore.signal()

        let urlSessionTaskID = downloadTask.taskIdentifier

        if self.downloader.isRestoredTask(urlSessionTaskID: urlSessionTaskID) {
            self.downloader.restoreTasksSemaphore.wait()
            self.downloader.restoreTasksSemaphore.signal()
        }

        self.downloader.updateDownloadedContentLength(urlSessionTaskID: urlSessionTaskID, length: totalBytesWritten)
        self.downloader.updateExpectedContentLength(
            urlSessionTaskID: urlSessionTaskID,
            length: totalBytesExpectedToWrite
        )
        self.downloader.reportProgress(urlSessionTaskID: urlSessionTaskID)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        _ = self.downloader.sessionInitSemaphore.wait(timeout: .now() + Downloader.waitDelay)
        self.downloader.sessionInitSemaphore.signal()

        let urlSessionTaskID = task.taskIdentifier

        if self.downloader.isRestoredTask(urlSessionTaskID: urlSessionTaskID) {
            self.downloader.restoreTasksSemaphore.wait()
            self.downloader.restoreTasksSemaphore.signal()
        }

        guard let err = error as NSError? else {
            return
        }

        NSLog("Downloader: received downloader delegate error method for downloadTask = \(task.taskIdentifier)")
        if err.code == NSURLErrorCancelled {
            self.downloader.invalidateTask(urlSessionTaskID: task.taskIdentifier)
            self.downloader.removeTask(urlSessionTaskID: task.taskIdentifier)
        } else {
            let resumeData = err.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            self.downloader.reportOnFailure(
                urlSessionTaskID: task.taskIdentifier,
                error: DownloaderError.clientSide(error: err)
            )
            self.downloader.markAsCanBeRestarted(urlSessionTaskID: task.taskIdentifier, buffer: resumeData)
        }
    }
}

// MARK: - Cache -

extension Downloader.Cache {
    var key: String {
        "downloaderCacheFor\(self.downloader.session.configuration.identifier ?? "")"
    }

    var defaults: UserDefaults { UserDefaults.standard }

    func flush() {
        var data = [[String: Any]]()
        for (urlTaskID, taskInfo) in self.downloader.tasks {
            data.append(
                [
                    Downloader.Cache.taskIDKey: taskInfo.task.id,
                    Downloader.Cache.urlTaskIDKey: urlTaskID,
                    Downloader.Cache.urlKey: taskInfo.task.url.absoluteString
                ]
            )
        }
        self.defaults.set(data, forKey: self.key)
        // Write on disk immediately to prevent cache losing
        self.defaults.synchronize()
    }

    func load() -> [(DownloaderTask, Int)] {
        var result = [(DownloaderTask, Int)]()
        for value in self.defaults.object(forKey: self.key) as? [[String: Any]] ?? [] {
            if let taskID = value[Downloader.Cache.taskIDKey] as? Int,
               let urlTaskID = value[Downloader.Cache.urlTaskIDKey] as? Int,
               let urlString = value[Downloader.Cache.urlKey] as? String,
               let url = URL(string: urlString) {
                result.append(
                    (DownloaderTask(id: taskID, url: url, executor: downloader, priority: .default), urlTaskID)
                )
            }
        }
        return result
    }
}

// MARK: - Downloader (RestorableBackgroundDownloaderProtocol) -

extension Downloader {
    var id: String? { self.session.configuration.identifier }

    var restoredTasks: [DownloaderTaskProtocol] { Array(self.restoredTasksMapping.values) }

    func resumeRestoredTasks() {
        defer {
            self.restoreTasksSemaphore.signal()
            NSLog("Downloader: resumed restored downloader tasks")
        }

        // Send cancel for all invalid tasks
        for (key, _) in self.restoredTasksMapping {
            if !self.validRestoredTasksIDs.contains(where: { $0 == key }) {
                self.invalidateRestoredTask(urlSessionTaskID: key)
            }
        }
    }
}
