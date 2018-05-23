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
}

enum ProfileMenuBlock: String {
    case infoHeader
    case notificationsSwitch
    case notificationsTimeSelection
    case description
    case pinsMap
}

class ProfilePresenter {
    weak var view: ProfileView?

    private var headerInfoPresenter: ProfileInfoPresenter?
    private var streakNotificationsPresenter: StreakNotificationsControlPresenter?

    private var userActivitiesAPI: UserActivitiesAPI
    private var usersAPI: UsersAPI
    private var notificationPermissionManager: NotificationPermissionManager

    private var userId: Int?

    var menu: Menu = Menu(blocks: [])

    init(userId: Int?, view: ProfileView, userActivitiesAPI: UserActivitiesAPI, usersAPI: UsersAPI, notificationPermissionManager: NotificationPermissionManager) {
        self.view = view
        self.userActivitiesAPI = userActivitiesAPI
        self.usersAPI = usersAPI
        self.notificationPermissionManager = notificationPermissionManager
        self.userId = userId

        initChildModules()
    }

    private func initChildModules() {
        // All presenters here should be passive

        // Header (name, avatar, streaks)
        if let attachedView = view?.getView(for: .infoHeader) as? ProfileInfoView {
            headerInfoPresenter = ProfileInfoPresenter(view: attachedView)
        }

        // Notifications control
        if let attachedView = view?.getView(for: .notificationsSwitch) as? StreakNotificationsControlView {
            streakNotificationsPresenter = StreakNotificationsControlPresenter(view: attachedView)
            if let streakNotificationsPresenter = streakNotificationsPresenter {
                attachedView.attachPresenter(streakNotificationsPresenter)
            }
        }
    }

    private func refreshUser(with user: User) {
        headerInfoPresenter?.update(with: user)
    }

    private func refreshStreak(with userActivity: UserActivity) {
        headerInfoPresenter?.update(with: userActivity)
    }

    func refresh() {
        guard let userId = self.userId else {
            self.view?.set(state: .error)
            return
        }

        loadProfile(userId: userId).then { [weak self] user in
            self?.refreshUser(with: user)
        }.catch { [weak self] error in
            print("profile presenter: error while user refreshing = \(error)")
            self?.view?.set(state: .error)
        }

        userActivitiesAPI.retrieve(user: userId).then { [weak self] activity in
            self?.refreshStreak(with: activity)
        }.catch { [weak self] error in
            print("profile presenter: error while streaks refreshing = \(error)")
        }
    }

    private func loadProfile(userId: Int) -> Promise<User> {
        return User.fetchAsync(ids: [userId]).then { [weak self] users -> Promise<[User]> in
            guard let s = self else { throw UnwrappingError.optionalError }

            return s.usersAPI.retrieve(ids: [userId], existing: users)
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
