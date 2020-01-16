import Foundation

protocol StreamVideoQualityStorageManagerProtocol: AnyObject {
    var globalStreamVideoQuality: StreamVideoQuality { get set }
}

final class StreamVideoQualityStorageManager: StreamVideoQualityStorageManagerProtocol {
    var globalStreamVideoQuality: StreamVideoQuality {
        get {
            if let qualityString = UserDefaults.standard.string(forKey: Key.streamVideoQuality.rawValue),
               let quality = StreamVideoQuality(qualityString: qualityString) {
                return quality
            } else {
                return DeviceInfo.current.isPad ? .high : .medium
            }
        }
        set {
            // Setting `string` value here because of legacy implementation.
            UserDefaults.standard.set(newValue.description, forKey: Key.streamVideoQuality.rawValue)
        }
    }

    private enum Key: String {
        case streamVideoQuality = "WatchingVideoQuality"
    }
}
