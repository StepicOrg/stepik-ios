import Foundation
import PromiseKit

protocol NewProfileUserActivityInteractorProtocol {
    func doUserActivityFetch(request: NewProfileUserActivity.ActivityLoad.Request)
}

final class NewProfileUserActivityInteractor: NewProfileUserActivityInteractorProtocol {
    private let presenter: NewProfileUserActivityPresenterProtocol
    private let provider: NewProfileUserActivityProviderProtocol

    private var currentUser: User?
    private var currentUserActivity: UserActivity?
    private var isCurrentUserProfile = false

    private var isOnline = false
    private var didLoadFromCache = false

    // To fetch only one user activity concurrently
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.NewProfileUserActivityInteractor.UserActivityFetch"
    )

    init(
        presenter: NewProfileUserActivityPresenterProtocol,
        provider: NewProfileUserActivityProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doUserActivityFetch(request: NewProfileUserActivity.ActivityLoad.Request) {
        guard let user = self.currentUser else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let isOnline = strongSelf.isOnline
            print("NewProfileUserActivityInteractor :: start fetching user activity, isOnline = \(isOnline)")

            strongSelf.fetchUserActivityInAppropriateMode(user: user, isOnline: isOnline).done { response in
                DispatchQueue.main.async {
                    print("NewProfileUserActivityInteractor :: finish fetching activity, isOnline = \(isOnline)")
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
    ) -> Promise<NewProfileUserActivity.ActivityLoad.Response> {
        Promise { seal in
            firstly {
                isOnline && self.didLoadFromCache
                    ? self.provider.fetchRemote(user: user)
                    : self.provider.fetchCached(user: user)
            }.done { userActivity in
                self.currentUserActivity = userActivity

                let data = NewProfileUserActivity.ActivityLoad.Data(
                    userActivity: userActivity,
                    isCurrentUserProfile: self.isCurrentUserProfile
                )

                seal.fulfill(.init(result: .success(data)))
            }.catch { error in
                if self.currentUserActivity == nil {
                    if self.isOnline && self.didLoadFromCache {
                        seal.reject(Error.networkFetchFailed)
                    } else {
                        seal.fulfill(.init(result: .failure(Error.cachedFetchFailed)))
                    }
                } else if case NewProfileUserActivityProvider.Error.networkFetchFailed = error,
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

extension NewProfileUserActivityInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {
        self.currentUser = user
        self.isCurrentUserProfile = isCurrentUserProfile
        self.isOnline = isOnline

        self.doUserActivityFetch(request: .init())
    }
}
