import Foundation

protocol ImageStoredFileManagerProtocol: AnyObject {
    func getImageStoredFile(imageURL: URL) -> StoredFileProtocol?
    func removeImageStoredFile(imageURL: URL) throws
    func saveTemporaryFileAsImageFile(temporaryFileURL: URL, imageURL: URL) throws -> StoredFileProtocol
    func makeImageFilenameFromImageDownloadURL(_ url: URL) -> String
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

        if let imageDataFile = self.overwriteFileContentsWithImageData(fileURL: storedFile.localURL) {
            return imageDataFile
        }

        return storedFile
    }

    // MARK: Protocol Conforming

    func makeImageFilenameFromImageDownloadURL(_ url: URL) -> String {
        let resultURL = url
            .deletingPathExtension()
            .absoluteString
            .components(separatedBy: .punctuationCharacters)
            .joined()
        return "\(resultURL).\(Self.fileExtension)"
    }

    func getImageStoredFile(imageURL: URL) -> StoredFileProtocol? {
        self.getLocalStoredFile(filename: self.makeImageFilenameFromImageDownloadURL(imageURL))
    }

    func removeImageStoredFile(imageURL: URL) throws {
        guard let imageFile = self.getImageStoredFile(imageURL: imageURL) else {
            throw Error.fileNotFound
        }

        return try self.removeLocalStoredFile(imageFile)
    }

    func saveTemporaryFileAsImageFile(temporaryFileURL: URL, imageURL: URL) throws -> StoredFileProtocol {
        let filename = self.makeImageFilenameFromImageDownloadURL(imageURL)
        return try self.moveStoredFile(from: temporaryFileURL, destinationFilename: filename)
    }

    // MARK: Private API

    private func overwriteFileContentsWithImageData(fileURL: URL) -> StoredFileProtocol? {
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
