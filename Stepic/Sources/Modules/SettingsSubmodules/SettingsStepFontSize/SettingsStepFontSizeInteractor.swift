import Foundation
import PromiseKit

protocol SettingsStepFontSizeInteractorProtocol {
    func doSomeAction(request: SettingsStepFontSize.SomeAction.Request)
}

final class SettingsStepFontSizeInteractor: SettingsStepFontSizeInteractorProtocol {
    weak var moduleOutput: SettingsStepFontSizeOutputProtocol?

    private let presenter: SettingsStepFontSizePresenterProtocol
    private let provider: SettingsStepFontSizeProviderProtocol

    init(
        presenter: SettingsStepFontSizePresenterProtocol,
        provider: SettingsStepFontSizeProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: SettingsStepFontSize.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension SettingsStepFontSizeInteractor: SettingsStepFontSizeInputProtocol { }