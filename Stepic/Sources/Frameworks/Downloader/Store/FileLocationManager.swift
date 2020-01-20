import Foundation

protocol FileLocationManagerProtocol: AnyObject {
    func getFullURLForFile(fileName: String) -> URL
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

    func getFullURLForFile(fileName: String) -> URL {
        self.filesDirectoryURL.appendingPathComponent(fileName, isDirectory: false)
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
