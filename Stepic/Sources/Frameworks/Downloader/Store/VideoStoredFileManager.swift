import Foundation

protocol VideoStoredFileManagerProtocol: AnyObject {
    func getVideoStoredFile(videoID: Video.IdType) -> StoredFileProtocol?
    func removeVideoStoredFile(videoID: Video.IdType) throws
    func saveTemporaryFileAsVideoFile(temporaryFileURL: URL, videoID: Video.IdType) throws -> StoredFileProtocol
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
        let filename = self.makeFileName(videoID: videoID)
        return self.getLocalStoredFile(filename: filename)
    }

    func removeVideoStoredFile(videoID: Video.IdType) throws {
        guard let file = self.getVideoStoredFile(videoID: videoID) else {
            throw Error.fileNotFound
        }

        return try self.removeLocalStoredFile(file)
    }

    func saveTemporaryFileAsVideoFile(temporaryFileURL: URL, videoID: Video.IdType) throws -> StoredFileProtocol {
        let filename = self.makeFileName(videoID: videoID)
        return try self.moveStoredFile(from: temporaryFileURL, destinationFilename: filename)
    }

    private func makeFileName(videoID: Video.IdType) -> String {
        "\(videoID).\(VideoStoredFileManager.fileExtension)"
    }

    enum Error: Swift.Error {
        case fileNotFound
    }
}
