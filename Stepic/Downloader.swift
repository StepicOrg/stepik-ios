//
//  Downloader.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class Downloader: DownloaderProtocol {
    // DownloaderImplementation can't implement delegate protocols
    // cause it doesn't extend NSObject
    fileprivate class Delegate: NSObject {
        var downloader: Downloader!

        init(downloader: Downloader) {
            self.downloader = downloader
        }
    }

    // Store additional information for each download task
    fileprivate class TaskInfo {
        let task: DownloaderTaskProtocol
        var urlSessionTask: URLSessionDownloadTask

        var expectedContentLength: Int64 = 0
        var downloadedContentLength: Int64 = 0

        var canBeRestarted = false
        var resumeDataAfterError: Data = Data(count: 0)

        init(task: DownloaderTaskProtocol, urlSessionTask: URLSessionDownloadTask) {
            self.task = task
            self.urlSessionTask = urlSessionTask
        }
    }

    /// Mapping URLSession id -> TaskInfo
    private var tasks: [Int: TaskInfo] = [:]
    /// Mapping DownloaderTask id -> URLSession id
    private var tasksMapping: [Int: Int] = [:]

    private func resume(urlSessionTaskId: Int) {
        let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId)

        // Re-init task with saved data
        // Or just resume current download
        if taskInfo.canBeRestarted {
            let resumeData = taskInfo.resumeDataAfterError
            let task = taskInfo.task

            removeTask(urlSessionTaskId: urlSessionTaskId)
            add(task: task, resumeData: resumeData)
            // canBeRestarted == false now
            resume(task: task)
        } else {
            taskInfo.task.set(state: .active)
            taskInfo.urlSessionTask.resume()
        }
    }

    private func pause(urlSessionTaskId: Int) {
        let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId)
        taskInfo.task.set(state: .paused)
        taskInfo.urlSessionTask.suspend()
    }

    private func cancel(urlSessionTaskId: Int) {
        let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId)
        taskInfo.task.set(state: .canceled)
        taskInfo.urlSessionTask.cancel()
    }

    private func reportOnCompletion(urlSessionTaskId: Int, location: URL) {
        let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId)
        taskInfo.task.set(state: .completed)
        taskInfo.task.completionReporter?(location)

        removeTask(urlSessionTaskId: urlSessionTaskId)
    }

    private func reportOnFailure(urlSessionTaskId: Int, error: Error) {
        getTaskInfo(urlSessionTaskId: urlSessionTaskId).task.failureReporter?(error)
    }

    private func reportProgress(urlSessionTaskId: Int) {
        let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId)
        let progress = Double(taskInfo.downloadedContentLength) / Double(taskInfo.expectedContentLength)

        taskInfo.task.set(state: .active)
        taskInfo.task.progressReporter?(Float(progress))
    }

    private func canStart(urlSessionTaskId: Int) -> Bool {
        if let taskInfo = tasks[urlSessionTaskId] {
            return tasksMapping[taskInfo.task.id] != nil
        }
        return false
    }

    private func updateExpectedContentLength(urlSessionTaskId: Int, length: Int64) {
        getTaskInfo(urlSessionTaskId: urlSessionTaskId).expectedContentLength = length
    }

    private func updateDownloadedContentLength(urlSessionTaskId: Int, length: Int64) {
        getTaskInfo(urlSessionTaskId: urlSessionTaskId).downloadedContentLength = length
    }

    private func invalidateTask(urlSessionTaskId: Int) {
        getTaskInfo(urlSessionTaskId: urlSessionTaskId).task.set(state: .canceled)
    }

    private func markAsCanBeRestarted(urlSessionTaskId: Int, buffer: Data?) {
        let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId)

        taskInfo.canBeRestarted = true
        taskInfo.resumeDataAfterError = buffer ?? Data(count: 0)
    }

    private func removeTask(urlSessionTaskId: Int) {
        let taskInfo = getTaskInfo(urlSessionTaskId: urlSessionTaskId)

        tasksMapping.removeValue(forKey: taskInfo.task.id)
        tasks.removeValue(forKey: urlSessionTaskId)
    }

    private func getTaskInfo(urlSessionTaskId: Int) -> TaskInfo {
        guard let taskInfo = tasks[urlSessionTaskId] else {
            fatalError("Downloader has no tasks with given ID!")
        }

        return taskInfo
    }

    private func add(task: DownloaderTaskProtocol, resumeData: Data?) {
        let delegate = Delegate(downloader: self)

        let configuration = URLSessionConfiguration.background(withIdentifier: "downloader_urlsession_\(Date().timeIntervalSince1970)")
        configuration.isDiscretionary = true

        let session = URLSession(configuration: configuration,
                                 delegate: delegate,
                                 delegateQueue: nil)

        var urlSessionDownloadTask: URLSessionDownloadTask
        if let resumeData = resumeData {
            urlSessionDownloadTask = session.downloadTask(withResumeData: resumeData)
        } else {
            urlSessionDownloadTask = session.downloadTask(with: task.url)
        }
        urlSessionDownloadTask.priority = task.priority.rawValue

        let taskInfo = TaskInfo(task: task, urlSessionTask: urlSessionDownloadTask)
        assert(taskInfo.canBeRestarted == false)

        tasksMapping[task.id] = urlSessionDownloadTask.taskIdentifier
        tasks[urlSessionDownloadTask.taskIdentifier] = taskInfo
    }
}

extension Downloader {
    func add(task: DownloaderTaskProtocol) {
        add(task: task, resumeData: nil)
    }

    func resume(task: DownloaderTaskProtocol) {
        guard let taskId = tasksMapping[task.id] else {
            return
        }

        resume(urlSessionTaskId: taskId)
    }

    func pause(task: DownloaderTaskProtocol) {
        guard let taskId = tasksMapping[task.id] else {
            return
        }

        pause(urlSessionTaskId: taskId)
    }

    func cancel(task: DownloaderTaskProtocol) {
        guard let taskId = tasksMapping[task.id] else {
            return
        }

        cancel(urlSessionTaskId: taskId)
    }
}

extension Downloader.Delegate: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        downloader.reportOnCompletion(urlSessionTaskId: downloadTask.taskIdentifier, location: location)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        downloader.updateDownloadedContentLength(urlSessionTaskId: downloadTask.taskIdentifier, length: fileOffset)
        downloader.updateExpectedContentLength(urlSessionTaskId: downloadTask.taskIdentifier, length: expectedTotalBytes)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloader.updateDownloadedContentLength(urlSessionTaskId: downloadTask.taskIdentifier, length: totalBytesWritten)
        downloader.updateExpectedContentLength(urlSessionTaskId: downloadTask.taskIdentifier, length: totalBytesExpectedToWrite)
        downloader.reportProgress(urlSessionTaskId: downloadTask.taskIdentifier)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let err = error as NSError? else {
            return
        }

        downloader.invalidateTask(urlSessionTaskId: task.taskIdentifier)
        if err.code == NSURLErrorCancelled {
            downloader.removeTask(urlSessionTaskId: task.taskIdentifier)
        } else {
            let resumeData = err.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            downloader.reportOnFailure(urlSessionTaskId: task.taskIdentifier, error: error!)
            downloader.markAsCanBeRestarted(urlSessionTaskId: task.taskIdentifier, buffer: resumeData)
        }
    }
}
