import Foundation

protocol DownloadVideoQualityStorageManagerProtocol: AnyObject {
    var downloadVideoQuality: DownloadVideoQuality { get set }
}

final class DownloadVideoQualityStorageManager: DownloadVideoQualityStorageManagerProtocol {
    var downloadVideoQuality: DownloadVideoQuality {
        get {
            if let qualityString = UserDefaults.standard.string(forKey: Key.downloadVideoQuality.rawValue),
               let quality = DownloadVideoQuality(qualityString: qualityString) {
                return quality
            } else {
                return DeviceInfo.current.isPad ? .high : .medium
            }
        }
        set {
            // Setting `string` value here because of legacy implementation.
            UserDefaults.standard.set(newValue.description, forKey: Key.downloadVideoQuality.rawValue)
        }
    }

    private enum Key: String {
        case downloadVideoQuality = "VideoQuality"
    }
}
