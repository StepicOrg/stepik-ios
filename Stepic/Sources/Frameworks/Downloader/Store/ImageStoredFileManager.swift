import Foundation

protocol ImageStoredFileManagerProtocol: AnyObject {
    func getImageStoredFile(imageURL: URL) -> StoredFileProtocol?
    func removeImageStoredFile(imageURL: URL) throws
    func saveTemporaryFileAsImageFile(temporaryFileURL: URL, imageURL: URL) throws -> StoredFileProtocol
}

final class ImageStoredFileManager: StoredFileManager, ImageStoredFileManagerProtocol {
    private static let fileExtension = "jpg"

    init(fileManager: FileManager) {
        super.init(
            fileManager: fileManager,
            fileLocationManager: FileLocationManagerFactory.makeLocationManager(type: .image)
        )
    }

    func getImageStoredFile(imageURL: URL) -> StoredFileProtocol? {
        let fileName = Self.makeFileName(imageURL: imageURL)
        return self.getLocalStoredFile(fileName: fileName)
    }

    func removeImageStoredFile(imageURL: URL) throws {
        guard let imageFile = self.getImageStoredFile(imageURL: imageURL) else {
            throw Error.fileNotFound
        }

        return try self.removeLocalStoredFile(imageFile)
    }

    func saveTemporaryFileAsImageFile(temporaryFileURL: URL, imageURL: URL) throws -> StoredFileProtocol {
        let fileName = Self.makeFileName(imageURL: imageURL)
        return try self.moveStoredFile(from: temporaryFileURL, destinationFileName: fileName)
    }

    static func makeFileName(imageURL: URL) -> String {
        let processedURL = imageURL
            .deletingPathExtension()
            .absoluteString
            .components(separatedBy: .punctuationCharacters)
            .joined()
        return "\(processedURL).\(Self.fileExtension)"
    }

    enum Error: Swift.Error {
        case fileNotFound
    }
}
