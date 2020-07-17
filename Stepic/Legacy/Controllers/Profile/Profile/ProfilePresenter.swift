//
//  ProfilePresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProfileView: AnyObject {
    func set(state: ProfileState)

    func showStreakTimeSelection(startHour: Int)
    func showAchievementInfo(viewData: AchievementViewData, canShare: Bool)

    func getView(for block: ProfileMenuBlock) -> Any?
    func setMenu(blocks: [ProfileMenuBlock])

    func manageBarItemControls(isSettingsHidden: Bool, isEditProfileAvailable: Bool, shareID: User.IdType?)
    func attachProfile(_ profile: Profile)
}

final class ProfilePresenter {
    enum UserSeed {
        case other(id: Int)
        case `self`(id: Int)
        case anonymous

        var isMe: Bool {
            if case UserSeed.`self`(_) = self { return true }
            return false
        }

        var userId: Int? {
            if case let UserSeed.`self`(id) = self { return id }
            if case let UserSeed.other(id) = self { return id }
            return nil
        }

        var analyticsString: String {
            switch self {
            case .anonymous:
                return "anonymous"
            case .self(id: _):
                return "self"
            case .other(id: _):
                return "other"
            }
        }
    }

    weak var view: ProfileView?

    private var headerInfoPresenter: ProfileInfoPresenter?
    private var streakNotificationsPresenter: StreakNotificationsControlPresenter?
    private var descriptionPresenter: ProfileDescriptionPresenter?
    private var pinsMapPresenter: PinsMapPresenter?
    //private var achievementsPresenter: ProfileAchievementsPresenter?

    private var userActivitiesAPI: UserActivitiesAPI
    private var usersAPI: UsersAPI
    private var profilesAPI: ProfilesAPI

    private var dataBackUpdateService: DataBackUpdateServiceProtocol

    var userSeed: UserSeed

    private var didProfileAttach = false

    private static let selfUserMenu: [ProfileMenuBlock] = [
        .infoHeader, .notificationsSwitch(isOn: false), .pinsMap, .certificates, .achievements, .description
    ]
    private static let otherUserMenu: [ProfileMenuBlock] = [
        .infoHeader, .pinsMap, .certificates, .achievements, .description
    ]

    init(
        userSeed: UserSeed,
        view: ProfileView,
        userActivitiesAPI: UserActivitiesAPI,
        usersAPI: UsersAPI,
        profilesAPI: ProfilesAPI,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.view = view
        self.userActivitiesAPI = userActivitiesAPI
        self.usersAPI = usersAPI
        self.userSeed = userSeed
        self.profilesAPI = profilesAPI

        self.dataBackUpdateService = dataBackUpdateService
        self.dataBackUpdateService.delegate = self
    }

    private func initChildModules(user: User, activity: UserActivity) {
        // All presenters here should be passive

        // Header (name, avatar, streaks)
        if let attachedView = view?.getView(for: .infoHeader) as? ProfileInfoView {
            headerInfoPresenter = ProfileInfoPresenter(view: attachedView)
        }

        // Notifications control
        if let attachedView = view?.getView(for: .notificationsSwitch(isOn: false)) as? StreakNotificationsControlView {
            streakNotificationsPresenter = StreakNotificationsControlPresenter(view: attachedView)
            if let streakNotificationsPresenter = streakNotificationsPresenter {
                attachedView.attachPresenter(streakNotificationsPresenter)
                streakNotificationsPresenter.refreshStreakNotificationTime()
            }
        }

        // Description
        if let attachedView = view?.getView(for: .description) as? ProfileDescriptionView {
            descriptionPresenter = ProfileDescriptionPresenter(view: attachedView)
        }

        // Pins map
        if let attachedView = view?.getView(for: .pinsMap) as? PinsMapContentView {
            pinsMapPresenter = PinsMapPresenter(view: attachedView)
        }

        // Achievements
//        if let attachedView = view?.getView(for: .achievements) as? ProfileAchievementsView,
//           let userId = userSeed.userId {
//            achievementsPresenter = ProfileAchievementsPresenter(userId: userId,
//                                                                 view: attachedView,
//                                                                 achievementsAPI: AchievementsAPI(),
//                                                                 achievementProgressesAPI: AchievementProgressesAPI())
//            if let achievementsPresenter = achievementsPresenter {
//                attachedView.attachPresenter(achievementsPresenter)
//                achievementsPresenter.delegate = self
//                achievementsPresenter.loadLastAchievements()
//            }
//        }

        refreshUser(with: user)
        refreshStreak(with: activity)
        headerInfoPresenter?.hideLoading()
    }

    private func refreshUser(with user: User) {
        headerInfoPresenter?.update(with: user)
        descriptionPresenter?.update(with: user)
    }

    private func refreshStreak(with userActivity: UserActivity) {
        headerInfoPresenter?.update(with: userActivity)
        pinsMapPresenter?.update(with: userActivity)
    }

    private func buildSelfUserMenu(blocks: [ProfileMenuBlock]) -> [ProfileMenuBlock] {
        var blocks = blocks
        let isNotificationOn = PreferencesContainer.notifications.allowStreaksNotifications

        for i in 0..<blocks.count {
            if case .notificationsSwitch(_) = blocks[i] {
                blocks[i] = ProfileMenuBlock.notificationsSwitch(isOn: isNotificationOn)

                if i + 1 < blocks.count && blocks[i + 1] == ProfileMenuBlock.notificationsTimeSelection {
                    blocks.remove(at: i + 1)
                }

                if isNotificationOn {
                    blocks.insert(.notificationsTimeSelection, at: i + 1)
                }
            }
        }

        if let userID = self.userSeed.userId {
            blocks.append(ProfileMenuBlock.userID(id: userID))
        }

        return blocks
    }

    func refresh(shouldReload: Bool = false) {
        if case .anonymous = self.userSeed {
            // Check case when we've init Profile for anonymous but now have logged user
            if AuthInfo.shared.isAuthorized, let userID = AuthInfo.shared.userId {
                self.userSeed = UserSeed.`self`(id: userID)
                return self.refresh(shouldReload: true)
            } else {
                self.view?.manageBarItemControls(isSettingsHidden: true, isEditProfileAvailable: false, shareID: nil)
                self.view?.set(state: .anonymous)
                return
            }
        }

        // We handle anonymous case (when userId is nil) above
        let userID = userSeed.userId!
        let isMe = self.userSeed.isMe

        // Check logout case
        if isMe && !AuthInfo.shared.isAuthorized {
            self.userSeed = .anonymous
            return self.refresh()
        }

        // Checking login case to another account.
        if isMe && AuthInfo.shared.isAuthorized && userID != AuthInfo.shared.userId {
            self.userSeed = .anonymous
            return self.refresh()
        }

        self.view?.manageBarItemControls(
            isSettingsHidden: !isMe,
            isEditProfileAvailable: self.didProfileAttach,
            shareID: userID
        )

        guard shouldReload else {
            return
        }

        self.view?.set(state: .loading)

        var user: User?
        self.loadProfile(userId: userID).then { [weak self] loadedUser -> Promise<(UserActivity, Profile?)> in
            user = loadedUser

            guard let strongSelf = self else {
                throw UnwrappingError.optionalError
            }

            // return strongSelf.userActivitiesAPI.retrieve(user: userId)
            return when(
                fulfilled: strongSelf.userActivitiesAPI.retrieve(user: userID),
                isMe ? strongSelf.profilesAPI.retrieve(id: loadedUser.profile).map { $0.first } : Promise.value(nil)
            )
        }.done { [weak self] activity, profile in
            guard let strongSelf = self else {
                throw UnwrappingError.optionalError
            }

            var menu = isMe
                ? strongSelf.buildSelfUserMenu(blocks: ProfilePresenter.selfUserMenu)
                : ProfilePresenter.otherUserMenu

            if let user = user {
                if user.isOrganization {
                    menu.removeAll(where: { $0 == .certificates })
                }

                strongSelf.view?.set(state: .normal)
                strongSelf.view?.setMenu(blocks: menu)
                strongSelf.initChildModules(user: user, activity: activity)
                strongSelf.view?.manageBarItemControls(
                    isSettingsHidden: !isMe,
                    isEditProfileAvailable: profile != nil,
                    shareID: userID
                )

                if let profile = profile {
                    strongSelf.didProfileAttach = true
                    strongSelf.view?.attachProfile(profile)
                }
            }
        }.catch { error in
            print("profile presenter: error while streaks refreshing = \(error)")
            self.view?.set(state: .error)
        }
    }

    private func loadProfile(userId: Int) -> Promise<User> {
        User.fetchAsync(ids: [userId]).then { [weak self] users -> Promise<[User]> in
            guard let strongSelf = self else {
                throw UnwrappingError.optionalError
            }

            return strongSelf.usersAPI.retrieve(ids: [userId], existing: users)
        }.then { users -> Promise<User> in
            if let user = users.first {
                return .value(user)
            } else {
                return Promise(error: ProfileError.noProfile)
            }
        }
    }

    enum ProfileError: Error {
        case noProfile
    }

    func sendAppearanceEvent() {
        StepikAnalytics.shared.send(.profileScreenOpened(state: userSeed.analyticsString))
    }
}

//extension ProfilePresenter: ProfileAchievementsPresenterDelegate {
//    func achievementInfoShouldPresent(viewData: AchievementViewData) {
//        view?.showAchievementInfo(viewData: viewData, canShare: userSeed.isMe)
//    }
//}

extension ProfilePresenter: DataBackUpdateServiceDelegate {
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
            self.headerInfoPresenter?.update(with: profile)
            self.descriptionPresenter?.update(with: profile)
        }
    }
}
