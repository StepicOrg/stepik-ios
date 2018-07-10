//
//  DownloaderTaskProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 10.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum DownloaderTaskPriority: Float {
    case low = 0.0
    case `default` = 0.5
    case high = 1.0
}

enum DownloaderTaskState {
    case inited
    case paused
    case active
    case completed
    case canceled
}

protocol DownloaderTaskProtocol: class {
    /// Task unique id
    var id: Int { get }
    /// Download URL
    var url: URL { get }
    /// Download priority
    var priority: DownloaderTaskPriority { get }

    /// Reporter block with progress 0.0 - 1.0
    var progressReporter: ((Float) -> Void)? { get set }
    /// Reporter block on completion
    var completionReporter: ((URL) -> Void)? { get set }
    /// Reporter block on failure
    var failureReporter: ((Error) -> Void)? { get set }

    init(url: URL, priority: DownloaderTaskPriority)

    /// Update task state
    func set(state: DownloaderTaskState)

    /// Add & run task with given executor
    func start(with executor: DownloaderProtocol)
    /// Add task to executor
    func add(to executor: DownloaderProtocol)
    /// Run task on selected executor
    func resume()
    /// Suspend task
    func pause()
    /// Cancel task (after this action task can't be resumed)
    func cancel()
}

extension DownloaderTaskProtocol {
    func start(with executor: DownloaderProtocol) {
        add(to: executor)
        resume()
    }
}
