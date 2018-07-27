//
//  VideoLocationManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class VideoLocationManager {
    private static var videosFolderName = "Video"
    private var documentDirectoryURL: URL

    var videosDirectoryURL: URL {
        return documentDirectoryURL.appendingPathComponent(VideoLocationManager.videosFolderName, isDirectory: true)
    }

    init(documentDirectoryURL: URL) {
        self.documentDirectoryURL = documentDirectoryURL
    }

    func getURLForVideo(id: Int, fileExtension: String) -> URL {
        let filename = "\(id).\(fileExtension)"
        return getURLForVideo(filename: filename)
    }

    func getURLForVideo(filename: String) -> URL {
        return videosDirectoryURL.appendingPathComponent(filename, isDirectory: false)
    }
}
