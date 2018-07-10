//
//  DownloaderTask.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class DownloaderTask: DownloaderTaskProtocol {
    private(set) var url: URL
    private(set) var priority: DownloaderTaskPriority
    private(set) var id: Int

    /// Task state
    private var state: DownloaderTaskState
    /// Current executor
    private(set) weak var executor: DownloaderProtocol?

    var progressReporter: ((_ progress: Float) -> Void)?
    var completionReporter: ((_ location: URL) -> Void)?
    var failureReporter: ((_ error: Error) -> Void)?

    required init(url: URL, priority: DownloaderTaskPriority = .default) {
        self.url = url
        self.priority = priority
        self.state = .inited

        self.id = url.hashValue &* Date().hashValue
    }

    func add(to executor: DownloaderProtocol) {
        guard state == .inited else {
            return
        }

        self.executor = executor
        executor.add(task: self)
    }

    func resume() {
        guard state == .inited || state == .paused || state == .canceled else {
            return
        }

        executor?.resume(task: self)
    }

    func pause() {
        guard state == .active else {
            return
        }

        executor?.pause(task: self)
    }

    func cancel() {
        guard state == .active else {
            return
        }

        executor?.cancel(task: self)
    }

    func set(state: DownloaderTaskState) {
        self.state = state
    }
}
