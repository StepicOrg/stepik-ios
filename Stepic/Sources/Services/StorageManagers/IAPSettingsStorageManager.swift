import Foundation

protocol IAPSettingsStorageManagerProtocol: AnyObject {
    var createCoursePaymentDelay: Double? { get set }
}

final class IAPSettingsStorageManager: IAPSettingsStorageManagerProtocol {
    var createCoursePaymentDelay: Double? {
        get {
            UserDefaults.standard.value(forKey: Key.createCoursePaymentDelay.rawValue) as? Double
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Key.createCoursePaymentDelay.rawValue)
        }
    }

    private enum Key: String {
        case createCoursePaymentDelay = "iapCreateCoursePaymentDelay"
    }
}
