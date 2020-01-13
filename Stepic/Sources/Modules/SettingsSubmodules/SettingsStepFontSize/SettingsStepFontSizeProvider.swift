import Foundation
import PromiseKit

protocol SettingsStepFontSizeProviderProtocol {
    func fetchAvailableFontSizes() -> Guarantee<[FontSize]>
    func fetchCurrentFontSize() -> Guarantee<FontSize>

    func setGlobalFontSize(_ fontSize: FontSize)
}

final class SettingsStepFontSizeProvider: SettingsStepFontSizeProviderProtocol {
    private let stepFontSizeService: StepFontSizeStorageManagerProtocol

    init(stepFontSizeService: StepFontSizeStorageManagerProtocol) {
        self.stepFontSizeService = stepFontSizeService
    }

    func fetchAvailableFontSizes() -> Guarantee<[FontSize]> {
        Guarantee { seal in
            seal(FontSize.allCases)
        }
    }

    func fetchCurrentFontSize() -> Guarantee<FontSize> {
        Guarantee { seal in
            seal(self.stepFontSizeService.globalStepFontSize)
        }
    }

    func setGlobalFontSize(_ fontSize: FontSize) {
        self.stepFontSizeService.globalStepFontSize = fontSize
    }
}
