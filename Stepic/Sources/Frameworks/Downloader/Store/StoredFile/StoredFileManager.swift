import Foundation

/// Abstract file on the disk (e.g video, image, saved step html, ...)
protocol StoredFileManagerProtocol: AnyObject {
    /// Find & get file info if file exists otherwise return nil
    func getLocalStoredFile(filename: String) -> StoredFileProtocol?
    /// Getting list of files in the documents directory
    func getAllStoredFiles() -> [StoredFileProtocol]
    /// Remove local stored video; throw exception if error occurred
    func removeLocalStoredFile(_ file: StoredFileProtocol) throws
    /// Move file to current location and return info about new file
    func moveStoredFile(from sourceURL: URL, destinationFilename: String) throws -> StoredFileProtocol
}

class StoredFileManager: StoredFileManagerProtocol {
    private(set) var fileManager: FileManager
    private(set) var fileLocationManager: FileLocationManagerProtocol

    init(
        fileManager: FileManager = FileManager.default,
        fileLocationManager: FileLocationManagerProtocol
    ) {
        self.fileManager = fileManager
        self.fileLocationManager = fileLocationManager
    }

    func getLocalStoredFile(filename: String) -> StoredFileProtocol? {
        let url = self.fileLocationManager.getFullURLForFile(filename: filename)

        if self.fileManager.fileExists(atPath: url.path),
           let size = self.getFileSize(url: url) {
            return StoredFile(localURL: url, size: size)
        }
        return nil
    }

    func getAllStoredFiles() -> [StoredFileProtocol] {
        guard let items = try? self.fileManager.contentsOfDirectory(
            at: self.fileLocationManager.filesDirectoryURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return items.compactMap { localURL in
            if let fileSize = self.getFileSize(url: localURL) {
                return StoredFile(localURL: localURL, size: fileSize)
            }
            return nil
        }
    }

    func removeLocalStoredFile(_ file: StoredFileProtocol) throws {
        do {
            try self.fileManager.removeItem(at: file.localURL)
        } catch {
            throw Error.unableToRemove
        }
    }

    func moveStoredFile(from sourceURL: URL, destinationFilename: String) throws -> StoredFileProtocol {
        let url = self.fileLocationManager.getFullURLForFile(filename: destinationFilename)

        do {
            // Try to get file folder before
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

    func getFileSize(url: URL) -> UInt64? {
        let attributes = try? self.fileManager.attributesOfItem(atPath: url.path)
        return attributes?[FileAttributeKey.size] as? UInt64
    }

    enum Error: Swift.Error {
        case unableToMove
        case unableToRemove
    }
}

// MARK: - StoredFileManagerFactory -

enum StoredFileManagerFactory {
    enum `Type` {
        case video
        case image
        case arQuickLook
    }

    static func makeStoredFileManager(type: Type) -> StoredFileManagerProtocol {
        switch type {
        case .video:
            return VideoStoredFileManager(fileManager: .default)
        case .image:
            return ImageStoredFileManager(fileManager: .default)
        case .arQuickLook:
            return ARQuickLookStoredFileManager(fileManager: .default)
        }
    }
}
