import Foundation

protocol AutoplayStorageManagerProtocol: AnyObject {
    var isAutoplayEnabled: Bool { get set }
}

final class AutoplayStorageManager: AutoplayStorageManagerProtocol {
    var isAutoplayEnabled: Bool {
        get {
            UserDefaults.standard.value(forKey: Key.autoplay.rawValue) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.autoplay.rawValue)
        }
    }

    private enum Key: String {
        case autoplay = "isAutoplayEnabled"
    }
}
