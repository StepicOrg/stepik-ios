import Foundation

protocol StreamVideoQualityStorageManagerProtocol: AnyObject {
    var streamVideoQuality: StreamVideoQuality { get set }
}

final class StreamVideoQualityStorageManager: StreamVideoQualityStorageManagerProtocol {
    var streamVideoQuality: StreamVideoQuality {
        get {
            if let qualityString = UserDefaults.standard.string(forKey: Key.streamVideoQuality.rawValue),
               let quality = StreamVideoQuality(qualityString: qualityString) {
                return quality
            } else {
                return DeviceInfo.current.isPad ? .high : .medium
            }
        }
        set {
            UserDefaults.standard.set(newValue.description, forKey: Key.streamVideoQuality.rawValue)
        }
    }

    private enum Key: String {
        case streamVideoQuality = "WatchingVideoQuality"
    }
}
