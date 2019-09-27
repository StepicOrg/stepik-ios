import Foundation
import PromiseKit

protocol SettingsStepFontSizeProviderProtocol {
    func fetchAvailableFontSizes() -> Guarantee<[FontSize]>
    func fetchCurrentFontSize() -> Guarantee<FontSize>

    func setGlobalFontSize(_ fontSize: FontSize)
}

final class SettingsStepFontSizeProvider: SettingsStepFontSizeProviderProtocol {
    private let stepFontSizeService: StepFontSizeServiceProtocol

    init(stepFontSizeService: StepFontSizeServiceProtocol) {
        self.stepFontSizeService = stepFontSizeService
    }

    func fetchAvailableFontSizes() -> Guarantee<[FontSize]> {
        return Guarantee { seal in
            seal(FontSize.allCases)
        }
    }

    func fetchCurrentFontSize() -> Guarantee<FontSize> {
        return Guarantee { seal in
            seal(self.stepFontSizeService.globalStepFontSize)
        }
    }

    func setGlobalFontSize(_ fontSize: FontSize) {
        self.stepFontSizeService.globalStepFontSize = fontSize
    }
}
