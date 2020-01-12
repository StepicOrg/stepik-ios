import Foundation
import PromiseKit

protocol NewSettingsInteractorProtocol {
    func doSomeAction(request: NewSettings.SomeAction.Request)
}

final class NewSettingsInteractor: NewSettingsInteractorProtocol {
    private let presenter: NewSettingsPresenterProtocol
    private let provider: NewSettingsProviderProtocol

    init(
        presenter: NewSettingsPresenterProtocol,
        provider: NewSettingsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: NewSettings.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}
