//
//  RestorableBackgroundDownloaderProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum RestorableBackgroundDownloaderError: Error {
    case invalidTask
}

protocol RestorableBackgroundDownloaderProtocol: DownloaderProtocol {
    var id: String? { get }
    var restoredTasks: [DownloaderTaskProtocol] { get }

    func resumeRestoredTasks()
}
