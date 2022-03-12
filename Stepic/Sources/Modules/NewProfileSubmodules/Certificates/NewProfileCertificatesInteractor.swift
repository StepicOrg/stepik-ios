import Foundation
import PromiseKit

protocol NewProfileCertificatesInteractorProtocol {
    func doCertificatesLoad(request: NewProfileCertificates.CertificatesLoad.Request)
    func doCertificateDetailPresentation(request: NewProfileCertificates.CertificateDetailPresentation.Request)
}

final class NewProfileCertificatesInteractor: NewProfileCertificatesInteractorProtocol {
    weak var moduleOutput: NewProfileCertificatesOutputProtocol?

    private let presenter: NewProfileCertificatesPresenterProtocol
    private let provider: NewProfileCertificatesProviderProtocol

    private var currentUser: User?
    private var currentCertificatesIDs = [Certificate.IdType]()

    private var isOnline = false
    private var didLoadFromCache = false

    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.NewProfileCertificatesInteractor.CertificatesFetch"
    )

    init(
        presenter: NewProfileCertificatesPresenterProtocol,
        provider: NewProfileCertificatesProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doCertificatesLoad(request: NewProfileCertificates.CertificatesLoad.Request) {
        guard let userID = self.currentUser?.id else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let isOnline = strongSelf.isOnline
            print("NewProfileCertificatesInteractor :: start fetching certificates, isOnline = \(isOnline)")

            strongSelf.fetchCertificatesInAppropriateMode(userID: userID, isOnline: isOnline).done { response in
                DispatchQueue.main.async {
                    print("NewProfileCertificatesInteractor :: finish fetching certificates, isOnline = \(isOnline)")
                    switch response.result {
                    case .success:
                        if strongSelf.currentCertificatesIDs.isEmpty {
                            if strongSelf.isOnline && strongSelf.didLoadFromCache {
                                strongSelf.moduleOutput?.handleEmptyCertificatesState()
                            }
                        } else {
                            strongSelf.presenter.presentCertificates(response: response)
                        }
                    case .failure:
                        break
                    }
                }
            }.ensure {
                if !strongSelf.didLoadFromCache {
                    strongSelf.didLoadFromCache = true
                    strongSelf.doCertificatesLoad(request: .init())
                }
                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                DispatchQueue.main.async {
                    strongSelf.presenter.presentCertificates(response: .init(result: .failure(error)))
                }
            }
        }
    }

    func doCertificateDetailPresentation(request: NewProfileCertificates.CertificateDetailPresentation.Request) {
        guard let certificateID = Int(request.viewModelUniqueIdentifier),
              self.currentCertificatesIDs.contains(certificateID) else {
            return
        }

        self.presenter.presentCertificateDetail(response: .init(certificateID: certificateID))
    }

    private func fetchCertificatesInAppropriateMode(
        userID: User.IdType,
        isOnline: Bool
    ) -> Promise<NewProfileCertificates.CertificatesLoad.Response> {
        Promise { seal in
            DispatchQueue.main.promise { () -> Promise<[Certificate]> in
                isOnline && self.didLoadFromCache
                    ? self.provider.fetchRemote(userID: userID)
                    : self.provider.fetchCached(userID: userID)
            }.done { certificates in
                self.currentCertificatesIDs = certificates.map(\.id)
                seal.fulfill(.init(result: .success(certificates)))
            }.catch { error in
                if case NewProfileCertificatesProvider.Error.networkFetchFailed = error,
                   self.didLoadFromCache,
                   !self.currentCertificatesIDs.isEmpty {
                    // Offline mode: we already presented cached certificates, but network request failed
                    // so let's ignore it and show only cached
                    seal.fulfill(.init(result: .failure(Error.networkFetchFailed)))
                } else {
                    seal.reject(error)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case networkFetchFailed
    }
}

extension NewProfileCertificatesInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {
        self.currentUser = user
        self.isOnline = isOnline

        self.doCertificatesLoad(request: .init())
    }
}
