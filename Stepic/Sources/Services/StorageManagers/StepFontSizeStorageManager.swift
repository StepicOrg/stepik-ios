import Foundation

protocol StepFontSizeStorageManagerProtocol: AnyObject {
    var globalStepFontSize: StepFontSize { get set }
}

final class StepFontSizeStorageManager: StepFontSizeStorageManagerProtocol {
    var globalStepFontSize: StepFontSize {
        get {
            guard let cachedValue = UserDefaults.standard.value(forKey: Key.stepFontSize.rawValue) as? Int else {
                self.setInDefaults(newFontSize: .small)
                return .small
            }

            return StepFontSize(rawValue: cachedValue) ?? .small
        }
        set {
            self.setInDefaults(newFontSize: newValue)
        }
    }

    private func setInDefaults(newFontSize: StepFontSize) {
        UserDefaults.standard.setValue(newFontSize.rawValue, forKey: Key.stepFontSize.rawValue)
    }

    private enum Key: String {
        case stepFontSize
    }
}
