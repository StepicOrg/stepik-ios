import Foundation

/// Abstract file on the disk (e.g video, image, saved step html, ...)
protocol StoredFileManagerProtocol: AnyObject {
    /// Find & get file info if file exists otherwise return nil
    func getLocalStoredFile(fileName: String) -> StoredFileProtocol?
    /// Remove local stored video; throw exception if error occurred
    func removeLocalStoredFile(_ file: StoredFileProtocol) throws
    /// Move file to current location and return info about new file
    func moveStoredFile(from sourceURL: URL, destinationFileName: String) throws -> StoredFileProtocol
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

    func moveStoredFile(from sourceURL: URL, destinationFileName: String) throws -> StoredFileProtocol {
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
        let attr = try? self.fileManager.attributesOfItem(atPath: url.path)
        return attr?[FileAttributeKey.size] as? UInt64
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
    }

    static func makeStoredFileManager(type: Type) -> StoredFileManagerProtocol {
        switch type {
        case .video:
            return VideoStoredFileManager(fileManager: .default)
        case .image:
            return ImageStoredFileManager(fileManager: .default)
        }
    }
}
