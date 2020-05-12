import Foundation
import PromiseKit

protocol NewProfileInteractorProtocol {
    func doProfileRefresh(request: NewProfile.ProfileLoad.Request)
    func doOnlineModeReset(request: NewProfile.OnlineModeReset.Request)
    func doProfileShareAction(request: NewProfile.ProfileShareAction.Request)
}

final class NewProfileInteractor: NewProfileInteractorProtocol {
    private let presentationDescription: NewProfile.PresentationDescription

    private let presenter: NewProfilePresenterProtocol
    private let provider: NewProfileProviderProtocol
    private let userAccountService: UserAccountServiceProtocol
    private let networkReachabilityService: NetworkReachabilityServiceProtocol

    private var currentUser: User?
    private var currentProfile: Profile?

    private var isOnline = false
    private var didLoadFromCache = false

    // To fetch only one user concurrently
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.NewProfileInteractor.UserFetch"
    )

    private var isCurrentUserProfile: Bool {
        switch self.presentationDescription.profileType {
        case .currentUser:
            return true
        case .otherUser:
            return false
        }
    }

    init(
        presentationDescription: NewProfile.PresentationDescription,
        presenter: NewProfilePresenterProtocol,
        provider: NewProfileProviderProtocol,
        userAccountService: UserAccountServiceProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol
    ) {
        self.presentationDescription = presentationDescription
        self.presenter = presenter
        self.provider = provider
        self.userAccountService = userAccountService
        self.networkReachabilityService = networkReachabilityService

        self.addObservers()
    }

    deinit {
        self.removeObservers()
    }

    // MARK: Public API

    func doProfileRefresh(request: NewProfile.ProfileLoad.Request) {
        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            DispatchQueue.main.async {
                strongSelf.updateNavigationControlsBasedOnCurrentState()
            }

            firstly { () -> Promise<NewProfile.ProfileLoad.Response> in
                switch strongSelf.presentationDescription.profileType {
                case .currentUser:
                    return strongSelf.fetchCurrentUser()
                case .otherUser(let profileUserID):
                    return strongSelf.fetchUserInAppropriateMode(userID: profileUserID)
                }
            }.done { response in
                // Ignore fulfilled errors, present only rejected ones.
                switch response.result {
                case .success:
                    DispatchQueue.main.async { [weak self] in
                        self?.presenter.presentProfile(response: response)
                    }
                case .failure:
                    break
                }
            }.ensure {
                DispatchQueue.main.async { [weak self] in
                    self?.updateNavigationControlsBasedOnCurrentState()
                }

                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                print("NewProfileInteractor :: profile refresh error = \(error)")

                DispatchQueue.main.async { [weak self] in
                    self?.presenter.presentProfile(response: .init(result: .failure(error)))
                }
            }
        }
    }

    func doOnlineModeReset(request: NewProfile.OnlineModeReset.Request) {
        let shouldSetOnlineMode = !self.isOnline && self.networkReachabilityService.isReachable

        if shouldSetOnlineMode {
            self.isOnline = true
            self.doProfileRefresh(request: .init())
        } else if self.isCurrentUserProfile {
            self.handleCurrentUserProfileStateCornerCases()
        }
    }

    func doProfileShareAction(request: NewProfile.ProfileShareAction.Request) {
        guard let currentUser = self.currentUser else {
            return
        }

        self.presenter.presentProfileSharing(response: .init(userID: currentUser.id))
    }

    // MARK: Private API

    private func fetchCurrentUser() -> Promise<NewProfile.ProfileLoad.Response> {
        guard self.userAccountService.isAuthorized,
              let currentUserID = self.userAccountService.currentUserID else {
            return Promise(error: Error.unauthorized)
        }

        return firstly {
            self.fetchUserInAppropriateMode(userID: currentUserID)
        }.then { response -> Promise<NewProfile.ProfileLoad.Response> in
            self.fetchCurrentUserProfile()
            return .value(response)
        }
    }

    private func fetchUserInAppropriateMode(userID: User.IdType) -> Promise<NewProfile.ProfileLoad.Response> {
        Promise { seal in
            firstly {
                self.isOnline && self.didLoadFromCache
                    ? self.provider.fetchRemoteUser(userID: userID)
                    : self.provider.fetchCachedUser(userID: userID)
            }.done { user in
                self.currentUser = user

                if let currentUser = self.currentUser {
                    seal.fulfill(.init(result: .success(currentUser)))
                } else {
                    // Offline mode: present empty state only if get nil from network
                    if self.isOnline && self.didLoadFromCache {
                        seal.reject(Error.networkFetchFailed)
                    } else {
                        seal.fulfill(.init(result: .failure(Error.cachedFetchFailed)))
                    }
                }

                if !self.didLoadFromCache {
                    self.didLoadFromCache = true
                }
            }.catch { error in
                if case NewProfileProvider.Error.networkFetchFailed = error,
                    self.didLoadFromCache,
                    self.currentUser != nil {
                    // Offline mode: we already presented cached profile, but network request failed
                    seal.fulfill(.init(result: .failure(Error.networkFetchFailed)))
                } else {
                    seal.reject(error)
                }
            }
        }
    }

    private func fetchCurrentUserProfile() {
        guard let currentUser = self.currentUser else {
            return
        }

        self.provider.fetchProfile(profileID: currentUser.id).done { profile in
            self.currentProfile = profile
        }.ensure {
            DispatchQueue.main.async {
                self.updateNavigationControlsBasedOnCurrentState()
            }
        }.catch { error in
            print("NewProfileInteractor :: current user profile load error = \(error)")
        }
    }

    private func handleCurrentUserProfileStateCornerCases() {
        // Check logout case.
        if self.currentUser != nil && !self.userAccountService.isAuthorized {
            return self.resetProfileStateToAnonymous()
        }

        // Check login case to another account.
        if let currentUser = self.currentUser {
            if self.userAccountService.isAuthorized && currentUser.id != self.userAccountService.currentUserID {
                return self.doProfileRefresh(request: .init())
            }
        }
    }

    private func updateNavigationControlsBasedOnCurrentState() {
        self.presenter.presentNavigationControls(
            response: .init(
                shoouldPresentSettings: self.isCurrentUserProfile,
                shoouldPresentEditProfile: self.isCurrentUserProfile && self.currentProfile != nil,
                shoouldPresentShareProfile: self.currentUser != nil
            )
        )
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case unauthorized
        case networkFetchFailed
        case cachedFetchFailed
    }
}

// MARK: - NewProfileInteractor (Observing Current User Profile) -

extension NewProfileInteractor {
    private func addObservers() {
        guard self.isCurrentUserProfile else {
            return
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleUserLoggedOutNotification),
            name: .didLogout,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleCurrentUserDidChangeNotification),
            name: .didChangeCurrentUser,
            object: nil
        )
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func handleUserLoggedOutNotification() {
        self.resetProfileStateToAnonymous()
    }

    @objc
    private func handleCurrentUserDidChangeNotification() {
        guard self.userAccountService.isAuthorized,
              let currentUser = self.userAccountService.currentUser else {
            return
        }

        self.currentUser = currentUser

        // Present cached user profile and then fetch actual info from remote.
        self.presenter.presentProfile(response: .init(result: .success(currentUser)))
        self.doProfileRefresh(request: .init())
    }
}

// MARK: - NewProfileInteractor: SettingsOutputProtocol -

extension NewProfileInteractor: SettingsOutputProtocol {
    func handleUserLoggedOut() {
        guard self.isCurrentUserProfile else {
            return
        }

        self.resetProfileStateToAnonymous()
        self.presenter.presentAuthorization(response: .init())
    }

    // MARK: Private Helpers

    private func resetProfileStateToAnonymous() {
        self.currentUser = nil
        self.currentProfile = nil

        self.updateNavigationControlsBasedOnCurrentState()
        // Present anonymous state.
        self.presenter.presentProfile(response: .init(result: .failure(Error.unauthorized)))
    }
}
