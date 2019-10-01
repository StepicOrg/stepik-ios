import UIKit

final class SettingsStepFontSizeAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = SettingsStepFontSizeProvider(stepFontSizeService: StepFontSizeService())
        let presenter = SettingsStepFontSizePresenter()
        let interactor = SettingsStepFontSizeInteractor(presenter: presenter, provider: provider)
        let viewController = SettingsStepFontSizeViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
