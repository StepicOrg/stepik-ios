import Foundation
import PromiseKit

protocol SettingsStepFontSizeProviderProtocol {
    func fetchAvailableFontSizes() -> Guarantee<[StepFontSize]>
    func fetchCurrentFontSize() -> Guarantee<StepFontSize>

    func setGlobalFontSize(_ fontSize: StepFontSize)
}

final class SettingsStepFontSizeProvider: SettingsStepFontSizeProviderProtocol {
    private let stepFontSizeService: StepFontSizeStorageManagerProtocol

    init(stepFontSizeService: StepFontSizeStorageManagerProtocol) {
        self.stepFontSizeService = stepFontSizeService
    }

    func fetchAvailableFontSizes() -> Guarantee<[StepFontSize]> {
        Guarantee { seal in
            seal(StepFontSize.allCases)
        }
    }

    func fetchCurrentFontSize() -> Guarantee<StepFontSize> {
        Guarantee { seal in
            seal(self.stepFontSizeService.globalStepFontSize)
        }
    }

    func setGlobalFontSize(_ fontSize: StepFontSize) {
        self.stepFontSizeService.globalStepFontSize = fontSize
    }
}
