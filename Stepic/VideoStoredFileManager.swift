//
//  VideoStoredFileManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol VideoStoredFileManagerProtocol: class {
    func getVideoStoredFile(videoID: Video.IdType) -> StoredFileProtocol?
    func removeVideoStoredFile(videoID: Video.IdType) throws
    func saveTemporaryFileAsVideoFile(
        temporaryFileURL: URL,
        videoID: Video.IdType
    ) throws -> StoredFileProtocol
}

final class VideoStoredFileManager: StoredFileManager, VideoStoredFileManagerProtocol {
    private static let fileExtension = "mp4"

    init(fileManager: FileManager) {
        super.init(
            fileManager: fileManager,
            fileLocationManager: FileLocationManagerFactory.makeLocationManager(type: .video)
        )
    }

    func getVideoStoredFile(videoID: Video.IdType) -> StoredFileProtocol? {
        let fileName = self.makeFileName(videoID: videoID)
        return self.getLocalStoredFile(fileName: fileName)
    }

    func removeVideoStoredFile(videoID: Video.IdType) throws {
        guard let file = self.getVideoStoredFile(videoID: videoID) else {
            throw Error.fileNotFound
        }

        return try self.removeLocalStoredFile(file)
    }

    func saveTemporaryFileAsVideoFile(
        temporaryFileURL: URL,
        videoID: Video.IdType
    ) throws -> StoredFileProtocol {
        let fileName = self.makeFileName(videoID: videoID)
        return try self.moveStoredFile(from: temporaryFileURL, destinationFileName: fileName)
    }

    private func makeFileName(videoID: Video.IdType) -> String {
        return "\(videoID).\(VideoStoredFileManager.fileExtension)"
    }

    enum Error: Swift.Error {
        case fileNotFound
    }
}

final class VideoLocationManager: FileLocationManagerProtocol {
    private static var videosFolderName = "Video"
    private var documentDirectoryURL: URL

    var videosDirectoryURL: URL {
        return self.documentDirectoryURL.appendingPathComponent(
            VideoLocationManager.videosFolderName,
            isDirectory: true
        )
    }

    init(documentDirectoryURL: URL) {
        self.documentDirectoryURL = documentDirectoryURL
    }

    func getFullURLForFile(fileName: String) -> URL {
        return self.videosDirectoryURL.appendingPathComponent(fileName, isDirectory: false)
    }
}
