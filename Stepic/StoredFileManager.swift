//
//  VideoFileManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

// MARK: Common protocols

protocol StoredFileProtocol {
    /// URL for stored video
    var localURL: URL { get }
    /// File size in bytes
    var size: UInt64 { get }
}

/// Abstract file on the disk (e.g video, image, saved step html, ...)
protocol StoredFileManagerProtocol: class {
    /// Find & get file info if file exists otherwise return nil
    func getLocalStoredFile(fileName: String) -> StoredFileProtocol?
    /// Remove local stored video; throw exception if error occured
    func removeLocalStoredFile(_ file: StoredFileProtocol) throws
    /// Move file to current location and return info about new file
    func moveStoredFile(
        from sourceURL: URL,
        destinationFileName: String
    ) throws -> StoredFileProtocol
}

protocol FileLocationManagerProtocol: class {
    func getFullURLForFile(fileName: String) -> URL
}

// MARK: Base file manager implementation

struct StoredFile: StoredFileProtocol {
    let localURL: URL
    let size: UInt64
}

class StoredFileManager: StoredFileManagerProtocol {
    private let fileManager: FileManager
    private let fileLocationManager: FileLocationManagerProtocol

    init(
        fileManager: FileManager = FileManager.default,
        fileLocationManager: FileLocationManagerProtocol
    ) {
        self.fileManager = fileManager
        self.fileLocationManager = fileLocationManager
    }

    func getLocalStoredFile(fileName: String) -> StoredFileProtocol? {
        let url = self.fileLocationManager.getFullURLForFile(fileName: fileName)

        if self.fileManager.fileExists(atPath: url.path),
           let size = self.getFileSize(url: url) {
            return StoredFile(localURL: url, size: size)
        }
        return nil
    }

    func removeLocalStoredFile(_ file: StoredFileProtocol) throws {
        do {
            try self.fileManager.removeItem(at: file.localURL)
        } catch {
            throw Error.unableToRemove
        }
    }

    func moveStoredFile(
        from sourceURL: URL,
        destinationFileName: String
    ) throws -> StoredFileProtocol {
        let url = self.fileLocationManager.getFullURLForFile(fileName: destinationFileName)

        do {
            // Try to get video folder before
            let directoryURL = url.deletingLastPathComponent()
            if !self.fileManager.fileExists(atPath: directoryURL.path) {
                try self.fileManager.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            }

            try self.fileManager.moveItem(at: sourceURL, to: url)

            let size = self.getFileSize(url: url) ?? 0
            return StoredFile(localURL: url, size: size)
        } catch {
            throw Error.unableToMove
        }
    }

    private func getFileSize(url: URL) -> UInt64? {
        let attr = try? fileManager.attributesOfItem(atPath: url.path)
        return attr?[FileAttributeKey.size] as? UInt64
    }

    enum Error: Swift.Error {
        case unableToMove
        case unableToRemove
    }
}

final class FileLocationManagerFactory {
    enum `Type` {
        case video
    }

    static func makeLocationManager(type: Type) -> FileLocationManagerProtocol {
        switch type {
        case .video:
            let fileManager = FileManager.default
            guard let url = try? fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ) else {
                fatalError("Document directory doesn't exist in user's home directory")
            }

            return VideoLocationManager(documentDirectoryURL: url)
        }
    }
}
