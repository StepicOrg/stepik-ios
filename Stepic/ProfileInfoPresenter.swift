//
//  ProfileInfoPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.05.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct ProfileViewData {
    var firstName: String
    var lastName: String
    var avatarUrl: URL?
}

struct StreakViewData {
    var didSolveToday: Bool
    var currentStreak: Int
    var longestStreak: Int
}

protocol ProfileInfoView: class {
    func set(profile: ProfileViewData)
    func set(streaks: StreakViewData)
}

class ProfileInfoPresenter {
    weak var view: ProfileInfoView?

    init(view: ProfileInfoView) {
        self.view = view
    }

    func update(with user: User) {
        let avatarUrl = URL(string: user.avatarURL)
        let profileData = ProfileViewData(firstName: user.firstName, lastName: user.lastName, avatarUrl: avatarUrl)
        view?.set(profile: profileData)
    }

    func update(with userActivity: UserActivity) {
        let streakData = StreakViewData(didSolveToday: userActivity.didSolveToday, currentStreak: userActivity.currentStreak, longestStreak: userActivity.longestStreak)
        view?.set(streaks: streakData)
    }
}
