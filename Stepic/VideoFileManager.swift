//
//  VideoFileManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum VideoFileManagerError: Error {
    case unableToMove
    case unableToRemove
}

class VideoFileManager {
    private var fileManager: FileManager
    private var videoLocationManager: VideoLocationManager
    private static let fileExtension = "mp4"

    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager

        guard let url = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            fatalError("Document directory doesn't exist in user's home directory")
        }

        self.videoLocationManager = VideoLocationManager(documentDirectoryURL: url)
    }

    func getVideoURL(videoId: Int) -> URL {
        return videoLocationManager.getURLForVideo(id: videoId, fileExtension: VideoFileManager.fileExtension)
    }

    func removeVideo(videoId: Int) throws {
        do {
            try fileManager.removeItem(at: getVideoURL(videoId: videoId))
        } catch {
            throw VideoFileManagerError.unableToRemove
        }
    }

    // FIXME: bad design, remove after core data migration
    func fileExists(videoId: Int) -> Bool {
        let url = videoLocationManager.getURLForVideo(id: videoId, fileExtension: VideoFileManager.fileExtension)

        return fileManager.fileExists(atPath: url.path)
    }

    func fileSize(videoId: Int) -> UInt64? {
        let url = videoLocationManager.getURLForVideo(id: videoId, fileExtension: VideoFileManager.fileExtension)
        let attr = try? fileManager.attributesOfItem(atPath: url.path)

        return attr?[FileAttributeKey.size] as? UInt64
    }

    func moveToVideoDirectory(videoId: Int, sourceURL: URL) throws {
        let destinationURL = videoLocationManager.getURLForVideo(id: videoId, fileExtension: VideoFileManager.fileExtension)

        do {
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
        } catch {
            throw VideoFileManagerError.unableToMove
        }
    }
}
