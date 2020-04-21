import Foundation

protocol FileLocationManagerProtocol: AnyObject {
    var filesDirectoryURL: URL { get }

    func getFullURLForFile(filename: String) -> URL
}

class FileLocationManager: FileLocationManagerProtocol {
    private let filesDirectoryName: String
    private let documentDirectoryURL: URL

    var filesDirectoryURL: URL {
        self.documentDirectoryURL.appendingPathComponent(self.filesDirectoryName, isDirectory: true)
    }

    init(filesDirectoryName: String, documentDirectoryURL: URL) {
        self.filesDirectoryName = filesDirectoryName
        self.documentDirectoryURL = documentDirectoryURL
    }

    func getFullURLForFile(filename: String) -> URL {
        self.filesDirectoryURL.appendingPathComponent(filename, isDirectory: false)
    }
}

final class VideoLocationManager: FileLocationManager {
    private static var videosDirectoryName = "Video"

    init(documentDirectoryURL: URL) {
        super.init(filesDirectoryName: Self.videosDirectoryName, documentDirectoryURL: documentDirectoryURL)
    }
}

final class ImageLocationManager: FileLocationManager {
    private static var imagesDirectoryName = "Image"

    init(documentDirectoryURL: URL) {
        super.init(filesDirectoryName: Self.imagesDirectoryName, documentDirectoryURL: documentDirectoryURL)
    }
}

final class ARQuickLookLocationManager: FileLocationManager {
    private static let arQuickLookDirectoryName: String = "ARQuickLook"

    init(documentDirectoryURL: URL) {
        super.init(filesDirectoryName: Self.arQuickLookDirectoryName, documentDirectoryURL: documentDirectoryURL)
    }
}

// MARK: - FileLocationManagerFactory -

enum FileLocationManagerFactory {
    enum `Type` {
        case video
        case image
        case arQuickLook
    }

    static func makeLocationManager(type: Type) -> FileLocationManagerProtocol {
        let fileManager = FileManager.default
        guard let documentsDirectoryURL = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            fatalError("Document directory doesn't exist in user's home directory")
        }

        switch type {
        case .video:
            return VideoLocationManager(documentDirectoryURL: documentsDirectoryURL)
        case .image:
            return ImageLocationManager(documentDirectoryURL: documentsDirectoryURL)
        case .arQuickLook:
            return ARQuickLookLocationManager(documentDirectoryURL: documentsDirectoryURL)
        }
    }
}
