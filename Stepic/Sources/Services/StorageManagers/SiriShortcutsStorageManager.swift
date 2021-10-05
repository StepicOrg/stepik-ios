import Foundation

@available(iOS 12.0, *)
protocol SiriShortcutsStorageManagerProtocol: AnyObject {
    var didClickFastContinueOnHomeWidget: Bool { get set }
    var didClickAddToSiriOnHomeWidget: Bool { get set }
}

@available(iOS 12.0, *)
extension SiriShortcutsStorageManagerProtocol {
    var shouldShowSiriButtonOnHomeWidget: Bool {
        self.didClickFastContinueOnHomeWidget && !self.didClickAddToSiriOnHomeWidget
    }
}

@available(iOS 12.0, *)
final class SiriShortcutsStorageManager: SiriShortcutsStorageManagerProtocol {
    var didClickFastContinueOnHomeWidget: Bool {
        get {
            UserDefaults.standard.bool(forKey: Key.didClickFastContinueOnHomeWidget.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.didClickFastContinueOnHomeWidget.rawValue)
        }
    }

    var didClickAddToSiriOnHomeWidget: Bool {
        get {
            UserDefaults.standard.bool(forKey: Key.didClickAddToSiriOnHomeWidget.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.didClickAddToSiriOnHomeWidget.rawValue)
        }
    }

    private enum Key: String {
        case didClickFastContinueOnHomeWidget
        case didClickAddToSiriOnHomeWidget
    }
}
