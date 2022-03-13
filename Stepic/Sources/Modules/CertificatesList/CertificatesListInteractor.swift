import Foundation
import PromiseKit

protocol CertificatesListInteractorProtocol {
    func doSomeAction(request: CertificatesList.SomeAction.Request)
}

final class CertificatesListInteractor: CertificatesListInteractorProtocol {
    weak var moduleOutput: CertificatesListOutputProtocol?

    private let presenter: CertificatesListPresenterProtocol
    private let provider: CertificatesListProviderProtocol

    init(
        presenter: CertificatesListPresenterProtocol,
        provider: CertificatesListProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: CertificatesList.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CertificatesListInteractor: CertificatesListInputProtocol {}
