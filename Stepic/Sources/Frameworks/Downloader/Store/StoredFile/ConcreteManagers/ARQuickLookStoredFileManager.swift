import Foundation

protocol ARQuickLookStoredFileManagerProtocol: AnyObject {
    func getARQuickLookStoredFile(url: URL) -> StoredFileProtocol?
    func removeARQuickLookStoredFile(url: URL) throws
    func makeARQuickLookFilenameFromDownloadURL(_ url: URL) -> String
}

final class ARQuickLookStoredFileManager: StoredFileManager, ARQuickLookStoredFileManagerProtocol {
    private static let fileExtension = "usdz"

    init(fileManager: FileManager) {
        super.init(
            fileManager: fileManager,
            fileLocationManager: FileLocationManagerFactory.makeLocationManager(type: .arQuickLook)
        )
    }

    // https://developer.apple.com/augmented-reality/quick-look/models/drummertoy/toy_drummer.usdz ->
    // httpsdeveloperapplecomaugmentedrealityquicklookmodelsdrummertoytoydrummer.usdz
    func makeARQuickLookFilenameFromDownloadURL(_ url: URL) -> String {
        let name = url
            .deletingPathExtension()
            .absoluteString
            .components(separatedBy: .punctuationCharacters)
            .joined()
        return "\(name).\(Self.fileExtension)"
    }

    func getARQuickLookStoredFile(url: URL) -> StoredFileProtocol? {
        self.getLocalStoredFile(filename: self.makeARQuickLookFilenameFromDownloadURL(url))
    }

    func removeARQuickLookStoredFile(url: URL) throws {
        guard let storedFile = self.getARQuickLookStoredFile(url: url) else {
            throw Error.fileNotFound
        }

        return try self.removeLocalStoredFile(storedFile)
    }

    enum Error: Swift.Error {
        case fileNotFound
    }
}
