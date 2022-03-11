import Foundation
import PromiseKit

protocol CertificateDetailInteractorProtocol {
    func doSomeAction(request: CertificateDetail.SomeAction.Request)
}

final class CertificateDetailInteractor: CertificateDetailInteractorProtocol {
    weak var moduleOutput: CertificateDetailOutputProtocol?

    private let presenter: CertificateDetailPresenterProtocol
    private let provider: CertificateDetailProviderProtocol

    init(
        presenter: CertificateDetailPresenterProtocol,
        provider: CertificateDetailProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: CertificateDetail.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CertificateDetailInteractor: CertificateDetailInputProtocol {}
