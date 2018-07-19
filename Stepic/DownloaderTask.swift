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

    /// Current executor
    private(set) weak var executor: DownloaderProtocol?

    var progressReporter: ((_ progress: Float?) -> Void)?

    var completionReporter: ((_ location: URL) -> Void)?

    var failureReporter: ((_ error: Error) -> Void)?

    var stateReporter: ((_ newState: DownloaderTaskState) -> Void)?

    var state: DownloaderTaskState {
        return executor?.getTaskState(for: self) ?? .detached
    }

    convenience init(url: URL, priority: DownloaderTaskPriority = .default) {
        self.init(id: Int(arc4random()), url: url, executor: nil, priority: priority)
    }

    init(id: Int, url: URL, executor: DownloaderProtocol? = nil, priority: DownloaderTaskPriority) {
        self.id = id
        self.url = url
        self.priority = priority
        self.executor = executor
    }

    func add(to executor: DownloaderProtocol) {
        self.executor = executor
        try? executor.add(task: self)
    }

    func resume() {
        try? executor?.resume(task: self)
    }

    func pause() {
        try? executor?.pause(task: self)
    }

    func cancel() {
        try? executor?.cancel(task: self)
    }
}
