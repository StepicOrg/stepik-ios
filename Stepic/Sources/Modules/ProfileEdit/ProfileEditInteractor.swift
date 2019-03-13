import Foundation
import PromiseKit

protocol ProfileEditInteractorProtocol {
    func doSomeAction(request: ProfileEdit.SomeAction.Request)
}

final class ProfileEditInteractor: ProfileEditInteractorProtocol {
    weak var moduleOutput: ProfileEditOutputProtocol?

    private let presenter: ProfileEditPresenterProtocol
    private let provider: ProfileEditProviderProtocol

    init(
        presenter: ProfileEditPresenterProtocol,
        provider: ProfileEditProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: ProfileEdit.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension ProfileEditInteractor: ProfileEditInputProtocol { }