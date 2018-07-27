//
//  VideoDownloaderManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class VideoDownloaderManager {
    static let shared = VideoDownloaderManager()

    private var downloader: Downloader
    // Mapping video id -> task
    private var downloads: [Int: VideoDownloaderTask] = [:]

    private init() {
        self.downloader = Downloader(session: .background(id: "video.main"))
        self.downloads = [:]
    }

    func start(task: VideoDownloaderTask) {
        task.start(with: downloader)
        store(task: task)
    }

    func store(task: VideoDownloaderTask) {
        downloads[task.videoId] = task
    }

    func remove(by videoId: Int) {
        downloads.removeValue(forKey: videoId)
    }

    func get(by videoId: Int) -> VideoDownloaderTask? {
        return downloads[videoId]
    }
}
