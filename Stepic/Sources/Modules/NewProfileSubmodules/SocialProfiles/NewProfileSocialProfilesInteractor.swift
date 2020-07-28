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
    private var didLoadFromRemote = false

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
            if strongSelf.didLoadFromRemote && hasEqualIDs {
                strongSelf.fetchSemaphore.signal()
                return
            }

            let isOnline = strongSelf.isOnline
            print("NewProfileSocialProfilesInteractor :: start fetching social profile, isOnline = \(isOnline)")

            strongSelf.fetchSocialProfilesInAppropriateMode(
                ids: user.socialProfilesArray,
                userID: user.id,
                isOnline: isOnline
            ).done { response in
                DispatchQueue.main.async {
                    print("NewProfileSocialProfilesInteractor :: finish fetching, isOnline = \(isOnline)")
                    strongSelf.presenter.presentSocialProfiles(response: response)
                }
            }.ensure {
                if !strongSelf.didLoadFromCache {
                    strongSelf.didLoadFromCache = true
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
            firstly {
                isOnline && self.didLoadFromCache
                    ? self.provider.fetchRemote(ids: ids, userID: userID)
                    : self.provider.fetchCached(ids: ids, userID: userID)
            }.done { socialProfiles in
                if isOnline && self.didLoadFromCache && !self.didLoadFromRemote {
                    self.didLoadFromRemote = true
                }

                self.currentSocialProfilesIDs = Set(socialProfiles.map(\.id))

                seal.fulfill(.init(result: .success(socialProfiles)))
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
    }
}

extension NewProfileSocialProfilesInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {
        self.currentUser = user
        self.isOnline = isOnline

        self.doSocialProfilesLoad(request: .init())
    }
}
