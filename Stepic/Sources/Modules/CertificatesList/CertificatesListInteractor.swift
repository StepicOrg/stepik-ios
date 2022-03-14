import Foundation
import PromiseKit

protocol CertificatesListInteractorProtocol {
    func doCertificatesLoad(request: CertificatesList.CertificatesLoad.Request)
    func doNextCertificatesLoad(request: CertificatesList.NextCertificatesLoad.Request)
    func doCertificateDetailPresentation(request: CertificatesList.CertificateDetailPresentation.Request)
}

final class CertificatesListInteractor: CertificatesListInteractorProtocol {
    private let presenter: CertificatesListPresenterProtocol
    private let provider: CertificatesListProviderProtocol

    private let userAccountService: UserAccountServiceProtocol
    private let analytics: Analytics

    private let userID: User.IdType

    private var currentCertificates = [Certificate]()
    private var paginationState = PaginationState(page: 1, hasNext: true)

    private var didLoadFromCache = false
    private var didPresentCertificates = false

    private var shouldSendOpenedAnalyticsEvent = true

    init(
        userID: User.IdType,
        presenter: CertificatesListPresenterProtocol,
        provider: CertificatesListProviderProtocol,
        userAccountService: UserAccountServiceProtocol,
        analytics: Analytics
    ) {
        self.userID = userID
        self.presenter = presenter
        self.provider = provider
        self.userAccountService = userAccountService
        self.analytics = analytics
    }

    func doCertificatesLoad(request: CertificatesList.CertificatesLoad.Request) {
        self.sendOpenedAnalyticsEventIfNeeded()

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

    func doNextCertificatesLoad(request: CertificatesList.NextCertificatesLoad.Request) {
        guard self.paginationState.hasNext else {
            return
        }

        let nextPageIndex = self.paginationState.page + 1

        self.provider.fetch(
            userID: self.userID,
            page: nextPageIndex,
            dataSourceType: .remote
        ).done { [weak self] certificates, meta in
            guard let strongSelf = self else {
                return
            }

            strongSelf.currentCertificates.append(contentsOf: certificates)
            strongSelf.paginationState = PaginationState(page: nextPageIndex, hasNext: meta.hasNext)

            let data = CertificatesList.CertificatesData(
                certificates: certificates,
                hasNextPage: meta.hasNext,
                isCurrentUser: strongSelf.userID == strongSelf.userAccountService.currentUserID
            )

            strongSelf.presenter.presentNextCertificates(response: .init(result: .success(data)))
        }.catch { [weak self] error in
            guard let strongSelf = self else {
                return
            }

            strongSelf.presenter.presentNextCertificates(response: .init(result: .failure(error)))
        }
    }

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
                    hasNextPage: response.1.hasNext,
                    isCurrentUser: self.userID == self.userAccountService.currentUserID
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

    private func sendOpenedAnalyticsEventIfNeeded() {
        guard self.shouldSendOpenedAnalyticsEvent else {
            return
        }

        self.shouldSendOpenedAnalyticsEvent = false

        self.analytics.send(
            .certificatesScreenOpened(
                userID: self.userID,
                certificateUserState: self.userID == self.userAccountService.currentUserID ? .`self` : .other
            )
        )
    }

    // MARK: Inner Types

    enum Error: Swift.Error {
        case cacheFetchFailed
        case remoteFetchFailed
    }
}

// MARK: - CertificatesListInteractor: CertificateDetailOutputProtocol -

extension CertificatesListInteractor: CertificateDetailOutputProtocol {
    func handleCertificateDetailDidChangeRecipientName(certificate: Certificate) {
        guard let index = self.currentCertificates.firstIndex(where: { $0.id == certificate.id }) else {
            return
        }

        self.currentCertificates[index] = certificate
    }
}
