import Foundation
import PromiseKit

protocol CertificatesListInteractorProtocol {
    func doCertificatesLoad(request: CertificatesList.CertificatesLoad.Request)
    func doNextCertificatesLoad(request: CertificatesList.NextCertificatesLoad.Request)
    func doCertificateDetailPresentation(request: CertificatesList.CertificateDetailPresentation.Request)
}

final class CertificatesListInteractor: CertificatesListInteractorProtocol {
    weak var moduleOutput: CertificatesListOutputProtocol?

    private let presenter: CertificatesListPresenterProtocol
    private let provider: CertificatesListProviderProtocol

    private let userID: User.IdType

    private var currentCertificates = [Certificate]()
    private var paginationState = PaginationState(page: 1, hasNext: true)

    private var didLoadFromCache = false
    private var didPresentCertificates = false

    init(
        userID: User.IdType,
        presenter: CertificatesListPresenterProtocol,
        provider: CertificatesListProviderProtocol
    ) {
        self.userID = userID
        self.presenter = presenter
        self.provider = provider
    }

    func doCertificatesLoad(request: CertificatesList.CertificatesLoad.Request) {
        self.fetchCertificatesInAppropriateMode().done { [weak self] data in
            guard let strongSelf = self else {
                return
            }

            strongSelf.currentCertificates = data.certificates
            strongSelf.paginationState = PaginationState(page: 1, hasNext: data.hasNextPage)

            let isCacheEmpty = !strongSelf.didLoadFromCache && data.certificates.isEmpty

            if isCacheEmpty {
                // Wait for remote fetch result.
            } else {
                strongSelf.didPresentCertificates = true
                strongSelf.presenter.presentCertificates(response: .init(result: .success(data)))
            }

            if !strongSelf.didLoadFromCache {
                strongSelf.didLoadFromCache = true
                strongSelf.doCertificatesLoad(request: .init())
            }
        }.catch { [weak self] error in
            guard let strongSelf = self else {
                return
            }

            if case Error.remoteFetchFailed = error,
               strongSelf.didLoadFromCache && !strongSelf.didPresentCertificates {
                strongSelf.presenter.presentCertificates(response: .init(result: .failure(error)))
            }
        }
    }

    func doNextCertificatesLoad(request: CertificatesList.NextCertificatesLoad.Request) {}

    func doCertificateDetailPresentation(request: CertificatesList.CertificateDetailPresentation.Request) {
        guard let certificate = self.currentCertificates.first(
            where: { "\($0.id)" == request.viewModelUniqueIdentifier }
        ) else {
            return
        }

        self.presenter.presentCertificateDetail(response: .init(certificateID: certificate.id))
    }

    // MARK: Private API

    private func fetchCertificatesInAppropriateMode() -> Promise<CertificatesList.CertificatesData> {
        let dataSourceType: DataSourceType = self.didLoadFromCache ? .remote : .cache

        return Promise { seal in
            self.provider.fetch(
                userID: self.userID,
                page: 1,
                dataSourceType: dataSourceType
            ).done { response in
                let data = CertificatesList.CertificatesData(
                    certificates: response.0,
                    hasNextPage: response.1.hasNext
                )
                seal.fulfill(data)
            }.catch { _ in
                switch dataSourceType {
                case .remote:
                    seal.reject(Error.remoteFetchFailed)
                case .cache:
                    seal.reject(Error.cacheFetchFailed)
                }
            }
        }
    }

    // MARK: Inner Types

    enum Error: Swift.Error {
        case cacheFetchFailed
        case remoteFetchFailed
    }
}

extension CertificatesListInteractor: CertificatesListInputProtocol {}

extension CertificatesListInteractor: CertificateDetailOutputProtocol {
    func handleCertificateDetailDidChangeRecipientName(certificate: Certificate) {}
}
