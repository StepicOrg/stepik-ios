import Foundation

protocol VideoRateStorageManagerProtocol: AnyObject {
    var videoRate: VideoRate { get set }
}

final class VideoRateStorageManager: VideoRateStorageManagerProtocol {
    var videoRate: VideoRate {
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
