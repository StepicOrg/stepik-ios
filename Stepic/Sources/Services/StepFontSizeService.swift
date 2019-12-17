import Foundation

protocol StepFontSizeServiceProtocol: AnyObject {
    var globalStepFontSize: FontSize { get set }
}

final class StepFontSizeService: StepFontSizeServiceProtocol {
    private static let sharedStepFontSizeKey = "stepFontSize"

    var globalStepFontSize: FontSize {
        get {
            guard let cachedValue = UserDefaults.standard.value(
                forKey: StepFontSizeService.sharedStepFontSizeKey
            ) as? Int else {
                self.setInDefaults(newFontSize: .small)
                return .small
            }

            return FontSize(rawValue: cachedValue) ?? .small
        }
        set {
            self.setInDefaults(newFontSize: newValue)
        }
    }

    private func setInDefaults(newFontSize: FontSize) {
        UserDefaults.standard.setValue(
            newFontSize.rawValue,
            forKey: StepFontSizeService.sharedStepFontSizeKey
        )
    }
}
