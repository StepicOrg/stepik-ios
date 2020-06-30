import Foundation
import PromiseKit

protocol NewProfileActivityInteractorProtocol {
    func doUserActivityFetch(request: NewProfileActivity.ActivityLoad.Request)
}

final class NewProfileActivityInteractor: NewProfileActivityInteractorProtocol {
    private let presenter: NewProfileActivityPresenterProtocol
    private let provider: NewProfileActivityProviderProtocol

    private var currentUser: User?
    private var currentUserActivity: UserActivity?

    private var isOnline = false
    private var didLoadFromCache = false

    // To fetch only one user concurrently
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.NewProfileActivityInteractor.UserActivityFetch"
    )

    init(
        presenter: NewProfileActivityPresenterProtocol,
        provider: NewProfileActivityProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doUserActivityFetch(request: NewProfileActivity.ActivityLoad.Request) {
        guard let user = self.currentUser else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let isOnline = strongSelf.isOnline
            print("NewProfileActivityInteractor :: start fetching user activity, isOnline = \(isOnline)")

            strongSelf.fetchUserActivityInAppropriateMode(user: user, isOnline: isOnline).done { response in
                DispatchQueue.main.async {
                    print("NewProfileActivityInteractor :: finish fetching activity, isOnline = \(isOnline)")
                    switch response.result {
                    case .success:
                        strongSelf.presenter.presentUserActivity(response: response)
                    case .failure:
                        break
                    }
                }
            }.ensure {
                if !strongSelf.didLoadFromCache {
                    strongSelf.didLoadFromCache = true
                    strongSelf.doUserActivityFetch(request: .init())
                }
                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                DispatchQueue.main.async {
                    strongSelf.presenter.presentUserActivity(response: .init(result: .failure(error)))
                }
            }
        }
    }

    private func fetchUserActivityInAppropriateMode(
        user: User,
        isOnline: Bool
    ) -> Promise<NewProfileActivity.ActivityLoad.Response> {
        Promise { seal in
            firstly {
                isOnline && self.didLoadFromCache
                    ? self.provider.fetchRemote(user: user)
                    : self.provider.fetchCached(user: user)
            }.done { userActivity in
                self.currentUserActivity = userActivity
                seal.fulfill(.init(result: .success(userActivity)))
            }.catch { error in
                if self.currentUserActivity == nil {
                    if self.isOnline && self.didLoadFromCache {
                        seal.reject(Error.networkFetchFailed)
                    } else {
                        seal.fulfill(.init(result: .failure(Error.cachedFetchFailed)))
                    }
                } else if case NewProfileActivityProvider.Error.networkFetchFailed = error,
                    self.didLoadFromCache {
                    // Offline mode: we already presented cached activity, but network request failed
                    seal.fulfill(.init(result: .failure(Error.networkFetchFailed)))
                } else {
                    seal.reject(error)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case networkFetchFailed
        case cachedFetchFailed
    }
}

extension NewProfileActivityInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isOnline: Bool) {
        self.currentUser = user
        self.isOnline = isOnline

        self.doUserActivityFetch(request: .init())
    }
}
