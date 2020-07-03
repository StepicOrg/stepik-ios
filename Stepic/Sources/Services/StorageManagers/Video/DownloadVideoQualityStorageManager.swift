import Foundation

protocol DownloadVideoQualityStorageManagerProtocol: AnyObject {
    var globalDownloadVideoQuality: DownloadVideoQuality { get set }
}

final class DownloadVideoQualityStorageManager: DownloadVideoQualityStorageManagerProtocol {
    var globalDownloadVideoQuality: DownloadVideoQuality {
        get {
            if let uniqueIdentifier = UserDefaults.standard.string(forKey: Key.downloadVideoQuality.rawValue),
               let value = DownloadVideoQuality(uniqueIdentifier: uniqueIdentifier) {
                return value
            } else {
                return DeviceInfo.current.isPad ? .high : .medium
            }
        }
        set {
            // Setting `string` value here because of legacy implementation.
            UserDefaults.standard.set(newValue.uniqueIdentifier, forKey: Key.downloadVideoQuality.rawValue)
        }
    }

    private enum Key: String {
        case downloadVideoQuality = "VideoQuality"
    }
}
