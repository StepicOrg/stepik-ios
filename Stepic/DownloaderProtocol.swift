//
//  DownloaderProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 10.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol DownloaderProtocol: class {
    /// Add task to downloader (w/o execution)
    func add(task: DownloaderTaskProtocol)
    /// Start or resume task (task should be added before)
    func resume(task: DownloaderTaskProtocol)
    /// Pause task (task should be added before)
    func pause(task: DownloaderTaskProtocol)
    /// Cancel task (task should be added before)
    func cancel(task: DownloaderTaskProtocol)
}
