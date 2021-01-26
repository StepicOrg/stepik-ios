import Foundation

@available(iOS 14.0, *)
protocol WidgetUserDefaultsProtocol: AnyObject {
    var isWidgetAdded: Bool { get set }
    var lastWidgetSize: Int { get set }
}

@available(iOS 14.0, *)
final class WidgetUserDefaults: WidgetUserDefaultsProtocol {
    private let userDefaults: UserDefaults

    init(suiteName: String) {
        self.userDefaults = UserDefaults(suiteName: suiteName).require()
    }

    var isWidgetAdded: Bool {
        get {
            self.userDefaults.bool(forKey: Key.homeScreenWidgetAdded.rawValue)
        }
        set {
            self.userDefaults.set(newValue, forKey: Key.homeScreenWidgetAdded.rawValue)
        }
    }

    var lastWidgetSize: Int {
        get {
            self.userDefaults.integer(forKey: Key.lastWidgetSize.rawValue)
        }
        set {
            self.userDefaults.set(newValue, forKey: Key.lastWidgetSize.rawValue)
        }
    }

    private enum Key: String {
        case homeScreenWidgetAdded
        case lastWidgetSize
    }
}

@available(iOS 14.0, *)
extension WidgetUserDefaults {
    static var `default`: WidgetUserDefaults {
        WidgetUserDefaults(suiteName: WidgetConstants.appGroupName)
    }
}
