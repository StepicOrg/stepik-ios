import Foundation
import PromiseKit

protocol NewProfileSocialProfilesInteractorProtocol {
    func doSocialProfilesLoad(request: NewProfileSocialProfiles.SocialProfilesLoad.Request)
}

final class NewProfileSocialProfilesInteractor: NewProfileSocialProfilesInteractorProtocol {
    private let presenter: NewProfileSocialProfilesPresenterProtocol
    private let provider: NewProfileSocialProfilesProviderProtocol

    private var currentUser: User?
    private var currentSocialProfilesIDs = Set<SocialProfile.IdType>()

    private var isOnline = false
    private var didLoadFromCache = false
    private var didLoadFromNetwork = false

    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.NewProfileSocialProfilesInteractor.SocialProfilesFetch"
    )

    init(
        presenter: NewProfileSocialProfilesPresenterProtocol,
        provider: NewProfileSocialProfilesProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSocialProfilesLoad(request: NewProfileSocialProfiles.SocialProfilesLoad.Request) {
        guard let user = self.currentUser else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let hasEqualIDs = Set(user.socialProfilesArray) == strongSelf.currentSocialProfilesIDs
            if !request.forceUpdate && strongSelf.didLoadFromNetwork && hasEqualIDs {
                strongSelf.fetchSemaphore.signal()
                return
            }

            let isOnline = request.forceUpdate ? true : strongSelf.isOnline
            print("NewProfileSocialProfilesInteractor :: start fetching social profile, isOnline = \(isOnline)")

            strongSelf.fetchSocialProfilesInAppropriateMode(
                ids: user.socialProfilesArray,
                userID: user.id,
                isOnline: isOnline
            ).done { response in
                DispatchQueue.main.async {
                    print("NewProfileSocialProfilesInteractor :: finish fetching, isOnline = \(isOnline)")
                    switch response.result {
                    case .success:
                        strongSelf.presenter.presentSocialProfiles(response: response)
                    case .failure:
                        break
                    }
                }
            }.ensure {
                if !strongSelf.didLoadFromCache {
                    strongSelf.didLoadFromCache = true
                    strongSelf.isOnline = true
                    strongSelf.doSocialProfilesLoad(request: .init())
                }
                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                DispatchQueue.main.async {
                    strongSelf.presenter.presentSocialProfiles(response: .init(result: .failure(error)))
                }
            }
        }
    }

    private func fetchSocialProfilesInAppropriateMode(
        ids: [SocialProfile.IdType],
        userID: User.IdType,
        isOnline: Bool
    ) -> Promise<NewProfileSocialProfiles.SocialProfilesLoad.Response> {
        Promise { seal in
            let shouldFetchRemote = isOnline && self.didLoadFromCache
            firstly {
                shouldFetchRemote
                    ? self.provider.fetchRemote(ids: ids, userID: userID)
                    : self.provider.fetchCached(ids: ids, userID: userID)
            }.done { socialProfiles in
                if shouldFetchRemote && !self.didLoadFromNetwork {
                    self.didLoadFromNetwork = true
                }

                self.currentSocialProfilesIDs = Set(socialProfiles.map(\.id))

                // There are no social profiles in cache, ignore and wait for network response.
                if self.currentSocialProfilesIDs.isEmpty && !shouldFetchRemote {
                    seal.fulfill(.init(result: .failure(Error.emptyCache)))
                } else {
                    seal.fulfill(.init(result: .success(socialProfiles)))
                }
            }.catch { error in
                if case NewProfileSocialProfilesProvider.Error.networkFetchFailed = error,
                   self.didLoadFromCache,
                   !self.currentSocialProfilesIDs.isEmpty {
                    // Offline mode: we already presented cached social profiles, but network request failed
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
        case fetchFailed
        case emptyCache
    }
}

extension NewProfileSocialProfilesInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {
        self.currentUser = user
        self.isOnline = isOnline

        self.doSocialProfilesLoad(request: .init())
    }
}
