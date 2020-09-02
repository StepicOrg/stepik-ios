import Foundation
import PromiseKit

protocol NewProfileInteractorProtocol {
    func doProfileRefresh(request: NewProfile.ProfileLoad.Request)
    func doOnlineModeReset(request: NewProfile.OnlineModeReset.Request)
    func doProfileShareAction(request: NewProfile.ProfileShareAction.Request)
    func doProfileEditAction(request: NewProfile.ProfileEditAction.Request)
    func doAchievementsListPresentation(request: NewProfile.AchievementsListPresentation.Request)
    func doCertificatesListPresentation(request: NewProfile.CertificatesListPresentation.Request)
    func doSubmodulesRegistration(request: NewProfile.SubmoduleRegistration.Request)
}

final class NewProfileInteractor: NewProfileInteractorProtocol {
    private let presentationDescription: NewProfile.PresentationDescription

    private let presenter: NewProfilePresenterProtocol
    private let provider: NewProfileProviderProtocol
    private let userAccountService: UserAccountServiceProtocol
    private let networkReachabilityService: NetworkReachabilityServiceProtocol
    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    private var currentUser: User? {
        didSet {
            self.pushCurrentUserToSubmodules(Array(self.submodules.values))
        }
    }
    private var currentProfile: Profile?

    private var submodules: [UniqueIdentifierType: NewProfileSubmoduleProtocol] = [:]

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
        networkReachabilityService: NetworkReachabilityServiceProtocol,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.presentationDescription = presentationDescription
        self.presenter = presenter
        self.provider = provider
        self.userAccountService = userAccountService
        self.networkReachabilityService = networkReachabilityService

        self.dataBackUpdateService = dataBackUpdateService
        self.dataBackUpdateService.delegate = self

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
                    return strongSelf.fetchCurrentUser(forceUpdate: request.forceUpdate)
                case .otherUser(let profileUserID):
                    return strongSelf.fetchUserInAppropriateMode(
                        userID: profileUserID,
                        forceUpdate: request.forceUpdate
                    )
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
        if let currentUser = self.currentUser {
            self.presenter.presentProfileSharing(response: .init(userID: currentUser.id))
        }
    }

    func doProfileEditAction(request: NewProfile.ProfileEditAction.Request) {
        if let currentProfile = self.currentProfile {
            self.presenter.presentProfileEditing(response: .init(profile: currentProfile))
        }
    }

    func doAchievementsListPresentation(request: NewProfile.AchievementsListPresentation.Request) {
        if let currentUserID = self.currentUser?.id {
            self.presenter.presentAchievementsList(response: .init(userID: currentUserID))
        }
    }

    func doCertificatesListPresentation(request: NewProfile.CertificatesListPresentation.Request) {
        if let currentUserID = self.currentUser?.id {
            self.presenter.presentCertificatesList(response: .init(userID: currentUserID))
        }
    }

    func doSubmodulesRegistration(request: NewProfile.SubmoduleRegistration.Request) {
        for (uniqueIdentifier, submodule) in request.submodules {
            self.submodules[uniqueIdentifier] = submodule
        }
        self.pushCurrentUserToSubmodules(Array(request.submodules.values))
    }

    // MARK: Private API

    private func fetchCurrentUser(forceUpdate: Bool) -> Promise<NewProfile.ProfileLoad.Response> {
        guard self.userAccountService.isAuthorized,
              let currentUserID = self.userAccountService.currentUserID else {
            return Promise(error: Error.unauthorized)
        }

        return firstly {
            self.fetchUserInAppropriateMode(userID: currentUserID, forceUpdate: forceUpdate)
        }.then { response -> Promise<NewProfile.ProfileLoad.Response> in
            self.fetchCurrentUserProfile()
            return .value(response)
        }
    }

    private func fetchUserInAppropriateMode(
        userID: User.IdType,
        forceUpdate: Bool
    ) -> Promise<NewProfile.ProfileLoad.Response> {
        Promise { seal in
            firstly {
                (self.isOnline && self.didLoadFromCache) || forceUpdate
                    ? self.provider.fetchRemoteUser(userID: userID)
                    : self.provider.fetchCachedUser(userID: userID)
            }.done { user in
                self.currentUser = user

                if let currentUser = self.currentUser {
                    seal.fulfill(
                        .init(result: .success(
                            .init(user: currentUser, isCurrentUserProfile: self.isCurrentUserProfile))
                        )
                    )
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
                shouldPresentSettings: self.isCurrentUserProfile,
                shouldPresentEditProfile: self.isCurrentUserProfile && self.currentProfile != nil,
                shouldPresentShareProfile: self.currentUser != nil
            )
        )
    }

    private func pushCurrentUserToSubmodules(_ submodules: [NewProfileSubmoduleProtocol]) {
        if let currentUser = self.currentUser {
            for submodule in submodules {
                submodule.update(
                    with: currentUser,
                    isCurrentUserProfile: self.isCurrentUserProfile,
                    isOnline: self.isOnline
                )
            }
        }
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
        self.presenter.presentProfile(
            response: .init(result: .success(.init(user: currentUser, isCurrentUserProfile: self.isCurrentUserProfile)))
        )
        self.doProfileRefresh(request: .init())
    }
}

// MARK: - NewProfileInteractor: NewProfileCertificatesOutputProtocol -

extension NewProfileInteractor: NewProfileCertificatesOutputProtocol {
    func handleEmptyCertificatesState() {
        self.presenter.presentSubmoduleEmptyState(response: .init(module: .certificates))
    }
}

// MARK: - NewProfileInteractor: NewProfileCreatedCoursesOutputProtocol -

extension NewProfileInteractor: NewProfileCreatedCoursesOutputProtocol {
    func handleCreatedCoursesEmptyState() {
        self.presenter.presentSubmoduleEmptyState(response: .init(module: .createdCourses))
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

// MARK: - NewProfileInteractor: DataBackUpdateServiceDelegate -

extension NewProfileInteractor: DataBackUpdateServiceDelegate {
    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport update: DataBackUpdateDescription,
        for target: DataBackUpdateTarget
    ) {}

    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport refreshedTarget: DataBackUpdateTarget
    ) {
        if case .profile(let profile) = refreshedTarget {
            guard self.isCurrentUserProfile, let currentUser = self.currentUser else {
                return
            }

            self.currentProfile = profile

            currentUser.firstName = profile.firstName
            currentUser.lastName = profile.lastName
            currentUser.bio = profile.shortBio
            currentUser.details = profile.details

            self.presenter.presentProfile(
                response: .init(result: .success(.init(user: currentUser, isCurrentUserProfile: true)))
            )
        }
    }
}
