import UIKit

final class SettingsStepFontSizeAssembly: Assembly {
    var moduleInput: SettingsStepFontSizeInputProtocol?

    private weak var moduleOutput: SettingsStepFontSizeOutputProtocol?

    init(output: SettingsStepFontSizeOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = SettingsStepFontSizeProvider()
        let presenter = SettingsStepFontSizePresenter()
        let interactor = SettingsStepFontSizeInteractor(presenter: presenter, provider: provider)
        let viewController = SettingsStepFontSizeViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}