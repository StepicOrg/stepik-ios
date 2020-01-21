import Foundation

protocol VideoRateStorageManagerProtocol: AnyObject {
    var globalVideoRate: VideoRate { get set }
}

final class VideoRateStorageManager: VideoRateStorageManagerProtocol {
    var globalVideoRate: VideoRate {
        get {
            if let rateValue = UserDefaults.standard.value(forKey: Key.videoRate.rawValue) as? Float,
               let videoRate = VideoRate(rawValue: rateValue) {
                return videoRate
            } else {
                return .normal
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.videoRate.rawValue)
        }
    }

    private enum Key: String {
        case videoRate = "VideoRate"
    }
}
