//
//  ProfilePresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProfileView: class {
    func set(state: ProfileState)

    func requestNotificationsPermissions()
    func showStreakTimeSelection(startHour: Int)
    func showAchievementInfo(viewData: AchievementViewData, canShare: Bool)

    func getView(for block: ProfileMenuBlock) -> Any?
    func setMenu(blocks: [ProfileMenuBlock])

    func manageSettingsTransitionControl(isHidden: Bool)
}

class ProfilePresenter {
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
    }

    weak var view: ProfileView?

    private var headerInfoPresenter: ProfileInfoPresenter?
    private var streakNotificationsPresenter: StreakNotificationsControlPresenter?
    private var descriptionPresenter: ProfileDescriptionPresenter?
    private var pinsMapPresenter: PinsMapPresenter?
    private var achievementsPresenter: ProfileAchievementsPresenter?

    private var userActivitiesAPI: UserActivitiesAPI
    private var usersAPI: UsersAPI
    private var notificationPermissionManager: NotificationPermissionManager

    private var userSeed: UserSeed

    private static let selfUserMenu: [ProfileMenuBlock] = [.infoHeader,
                                                           .notificationsSwitch(isOn: false),
                                                           .pinsMap,
                                                           .achievements,
                                                           .description]
    private static let otherUserMenu: [ProfileMenuBlock] = [.infoHeader, .pinsMap, .achievements, .description]

    init(userSeed: UserSeed, view: ProfileView, userActivitiesAPI: UserActivitiesAPI, usersAPI: UsersAPI, notificationPermissionManager: NotificationPermissionManager) {
        self.view = view
        self.userActivitiesAPI = userActivitiesAPI
        self.usersAPI = usersAPI
        self.notificationPermissionManager = notificationPermissionManager
        self.userSeed = userSeed
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
        if let attachedView = view?.getView(for: .achievements) as? ProfileAchievementsView,
           let userId = userSeed.userId {
            achievementsPresenter = ProfileAchievementsPresenter(userId: userId,
                                                                 view: attachedView,
                                                                 achievementsAPI: AchievementsAPI(),
                                                                 achievementProgressesAPI: AchievementProgressesAPI())
            if let achievementsPresenter = achievementsPresenter {
                attachedView.attachPresenter(achievementsPresenter)
                achievementsPresenter.delegate = self
                achievementsPresenter.loadLastAchievements()
            }
        }

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
            if case ProfileMenuBlock.notificationsSwitch(_) = blocks[i] {
                blocks[i] = ProfileMenuBlock.notificationsSwitch(isOn: isNotificationOn)

                if i + 1 < blocks.count && blocks[i + 1] == ProfileMenuBlock.notificationsTimeSelection {
                    blocks.remove(at: i + 1)
                }

                if isNotificationOn {
                    blocks.insert(.notificationsTimeSelection, at: i + 1)
                }
            }
        }

        return blocks
    }

    func refresh(shouldReload: Bool = false) {
        if case UserSeed.anonymous = userSeed {
            // Check case when we've init Profile for anonymous but now have logged user
            if AuthInfo.shared.isAuthorized, let userId = AuthInfo.shared.userId {
                userSeed = UserSeed.`self`(id: userId)
                return refresh(shouldReload: true)
            } else {
                view?.manageSettingsTransitionControl(isHidden: true)
                view?.set(state: .anonymous)
                return
            }
        }

        // We handle anonymous case (when userId is nil) above
        let userId = userSeed.userId!
        let isMe = userSeed.isMe

        // Check logout case
        if isMe && !AuthInfo.shared.isAuthorized {
            userSeed = .anonymous
            return refresh()
        }

        view?.manageSettingsTransitionControl(isHidden: !isMe)

        guard shouldReload else {
            return
        }
        view?.set(state: .loading)

        var user: User?
        loadProfile(userId: userId).then { [weak self] loadedUser -> Promise<UserActivity> in
            user = loadedUser

            guard let strongSelf = self else {
                throw UnwrappingError.optionalError
            }

            return strongSelf.userActivitiesAPI.retrieve(user: userId)
        }.done { [weak self] activity in
            guard let strongSelf = self else {
                throw UnwrappingError.optionalError
            }

            let menu = isMe ? strongSelf.buildSelfUserMenu(blocks: ProfilePresenter.selfUserMenu)
                                                        : ProfilePresenter.otherUserMenu

            if let user = user {
                strongSelf.view?.set(state: .normal)
                strongSelf.view?.setMenu(blocks: menu)
                strongSelf.initChildModules(user: user, activity: activity)
            }
        }.catch { error in
            print("profile presenter: error while streaks refreshing = \(error)")
            self.view?.set(state: .error)
        }
    }

    private func loadProfile(userId: Int) -> Promise<User> {
        return User.fetchAsync(ids: [userId]).then { [weak self] users -> Promise<[User]> in
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
}

extension ProfilePresenter: ProfileAchievementsPresenterDelegate {
    func achievementInfoShouldPresent(viewData: AchievementViewData) {
        view?.showAchievementInfo(viewData: viewData, canShare: userSeed.isMe)
    }
}
