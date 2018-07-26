//
//  VideoDownloaderTask.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class VideoDownloaderTask: DownloaderTask {
    var videoId: Int
    var progress: Float = 0

    private var completionReporters: [((URL) -> Void)] = []
    private var progressReporters: [((Float?) -> Void)] = []
    private var failureReporters: [((Error) -> Void)] = []

    // FIXME: progressReporter and other reporters should available only via appendReporter()
    override var progressReporter: ((Float?) -> Void)? {
        set {
            if let newValue = newValue {
                self.progressReporters.append(newValue)
            }
        }
        get {
            let wrappedReporter: ((Float?) -> Void) = { [weak self] progress in
                // Skip unknown progress
                self?.progress = progress ?? 0
                self?.progressReporters.forEach { $0(progress) }
            }
            return wrappedReporter
        }
    }

    override var completionReporter: ((URL) -> Void)? {
        set {
            if let newValue = newValue {
                self.completionReporters.append(newValue)
            }
        }
        get {
            let wrappedReporter: ((URL) -> Void) = { [weak self] url in
                self?.moveAfterCompletion(url: url)
                self?.completionReporters.forEach { $0(url) }
            }
            return wrappedReporter
        }
    }

    override var failureReporter: ((Error) -> Void)? {
        set {
            if let newValue = newValue {
                self.failureReporters.append(newValue)
            }
        }
        get {
            let wrappedReporter: ((Error) -> Void) = { [weak self] error in
                self?.failureReporters.forEach { $0(error) }
            }
            return wrappedReporter
        }
    }

    init(videoId: Int, url: URL) {
        self.videoId = videoId
        let id = videoId.hashValue &* Int(arc4random())
        super.init(id: id, url: url, executor: nil, priority: .default)
    }

    private func moveAfterCompletion(url: URL) {
        let fileManager = VideoFileManager()

        do {
            try fileManager.moveToVideoDirectory(videoId: videoId, sourceURL: url)
        } catch {
            self.failureReporter?(error)
        }
    }
}
