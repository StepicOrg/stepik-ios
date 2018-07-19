//
//  DownloaderProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 10.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum DownloaderSessionType {
    case background(id: String)
    case foreground
}

enum DownloaderError: Error {
    case serverSide(statusCode: Int?)
    case incorrectState
    case detachedState
    case clientSide(error: NSError)
}

protocol DownloaderProtocol: class {
    /// Add task to downloader (w/o execution)
    func add(task: DownloaderTaskProtocol) throws
    /// Start or resume task (task should be added before)
    func resume(task: DownloaderTaskProtocol) throws
    /// Pause task (task should be added before)
    func pause(task: DownloaderTaskProtocol) throws
    /// Cancel task (task should be added before)
    func cancel(task: DownloaderTaskProtocol) throws
    /// Get state for task
    func getTaskState(for task: DownloaderTaskProtocol) -> DownloaderTaskState?

    /// Init downloader with given session type
    init(session: DownloaderSessionType)
}
