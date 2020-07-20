import Foundation
import PromiseKit

protocol NewProfileCertificatesInteractorProtocol {
    func doSomeAction(request: NewProfileCertificates.SomeAction.Request)
}

final class NewProfileCertificatesInteractor: NewProfileCertificatesInteractorProtocol {
    private let presenter: NewProfileCertificatesPresenterProtocol
    private let provider: NewProfileCertificatesProviderProtocol

    init(
        presenter: NewProfileCertificatesPresenterProtocol,
        provider: NewProfileCertificatesProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: NewProfileCertificates.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension NewProfileCertificatesInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {}
}
