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

    func getView(for block: ProfileMenuBlock) -> Any?
    func setMenu(blocks: [ProfileMenuBlock])

    func manageSettingsTransitionControl(isHidden: Bool)
}

enum ProfileMenuBlock: RawRepresentable, Equatable {
    typealias RawValue = String

    case infoHeader
    case notificationsSwitch(isOn: Bool)
    case notificationsTimeSelection
    case description
    case pinsMap

    init?(rawValue: RawValue) {
        fatalError("init with raw value has not been implemented")
    }

    var rawValue: RawValue {
        switch self {
        case .infoHeader:
            return "infoHeader"
        case .notificationsSwitch(_):
            return "notificationsSwitch"
        case .notificationsTimeSelection:
            return "notificationsTimeSelection"
        case .description:
            return "description"
        case .pinsMap:
            return "pinsMap"
        }
    }

    static func ==(lhs: ProfileMenuBlock, rhs: ProfileMenuBlock) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

class ProfilePresenter {
    weak var view: ProfileView?

    private var headerInfoPresenter: ProfileInfoPresenter?
    private var streakNotificationsPresenter: StreakNotificationsControlPresenter?
    private var descriptionPresenter: ProfileDescriptionPresenter?
    private var pinsMapPresenter: PinsMapPresenter?

    private var userActivitiesAPI: UserActivitiesAPI
    private var usersAPI: UsersAPI
    private var notificationPermissionManager: NotificationPermissionManager

    private var userId: Int

    private static let selfUserMenu: [ProfileMenuBlock] = [.infoHeader,
                                                           .notificationsSwitch(isOn: false),
                                                           .pinsMap,
                                                           .description]
    private static let otherUserMenu: [ProfileMenuBlock] = [.infoHeader, .pinsMap, .description]

    init(userId: Int, view: ProfileView, userActivitiesAPI: UserActivitiesAPI, usersAPI: UsersAPI, notificationPermissionManager: NotificationPermissionManager) {
        self.view = view
        self.userActivitiesAPI = userActivitiesAPI
        self.usersAPI = usersAPI
        self.notificationPermissionManager = notificationPermissionManager
        self.userId = userId
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

    func refresh() {
        let isMe = userId == AuthInfo.shared.userId
        view?.manageSettingsTransitionControl(isHidden: !isMe)

        var user: User?
        loadProfile(userId: userId).then { [weak self] loadedUser -> Promise<UserActivity> in
            user = loadedUser

            guard let strongSelf = self else {
                throw UnwrappingError.optionalError
            }

            return strongSelf.userActivitiesAPI.retrieve(user: strongSelf.userId)
        }.then { [weak self] activity -> Void in
            guard let strongSelf = self else {
                throw UnwrappingError.optionalError
            }

            let menu = isMe ? strongSelf.buildSelfUserMenu(blocks: ProfilePresenter.selfUserMenu)
                                                        : ProfilePresenter.otherUserMenu

            if let user = user {
                strongSelf.view?.setMenu(blocks: menu)
                strongSelf.initChildModules(user: user, activity: activity)
            }
        }.catch { error in
            print("profile presenter: error while streaks refreshing = \(error)")
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
                return Promise(value: user)
            } else {
                return Promise(error: ProfileError.noProfile)
            }
        }
    }

    enum ProfileError: Error {
        case noProfile
    }
}
