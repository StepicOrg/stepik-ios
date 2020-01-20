import Foundation

enum FileLocationManagerFactory {
    enum `Type` {
        case video
        case image
    }

    static func makeLocationManager(type: Type) -> FileLocationManagerProtocol {
        let fileManager = FileManager.default
        guard let documentDirectoryURL = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            fatalError("Document directory doesn't exist in user's home directory")
        }

        switch type {
        case .video:
            return VideoLocationManager(documentDirectoryURL: documentDirectoryURL)
        case .image:
            return ImageLocationManager(documentDirectoryURL: documentDirectoryURL)
        }
    }
}
