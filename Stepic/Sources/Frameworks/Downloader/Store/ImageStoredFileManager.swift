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

    override func moveStoredFile(from sourceURL: URL, destinationFilename: String) throws -> StoredFileProtocol {
        let storedFile = try super.moveStoredFile(from: sourceURL, destinationFilename: destinationFilename)

        if let imageDataStoredFile = self.overwriteWithImageData(fileURL: storedFile.localURL) {
            return imageDataStoredFile
        }

        return storedFile
    }

    static func makeFilename(imageDownloadURL: URL) -> String {
        let processedURL = imageDownloadURL
            .deletingPathExtension()
            .absoluteString
            .components(separatedBy: .punctuationCharacters)
            .joined()
        return "\(processedURL).\(Self.fileExtension)"
    }

    func getImageStoredFile(imageURL: URL) -> StoredFileProtocol? {
        let fileName = Self.makeFilename(imageDownloadURL: imageURL)
        return self.getLocalStoredFile(filename: fileName)
    }

    func removeImageStoredFile(imageURL: URL) throws {
        guard let imageFile = self.getImageStoredFile(imageURL: imageURL) else {
            throw Error.fileNotFound
        }

        return try self.removeLocalStoredFile(imageFile)
    }

    func saveTemporaryFileAsImageFile(temporaryFileURL: URL, imageURL: URL) throws -> StoredFileProtocol {
        let filename = Self.makeFilename(imageDownloadURL: imageURL)
        return try self.moveStoredFile(from: temporaryFileURL, destinationFilename: filename)
    }

    private func overwriteWithImageData(fileURL: URL) -> StoredFileProtocol? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        guard let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }

        do {
            try jpegData.write(to: fileURL)
            let size = self.getFileSize(url: fileURL) ?? 0

            return StoredFile(localURL: fileURL, size: size)
        } catch {
            return nil
        }
    }

    enum Error: Swift.Error {
        case fileNotFound
    }
}
