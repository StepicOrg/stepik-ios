//
//  ProfilePresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol ProfileView: class {
    func presentStreak()
    func setLearningNotifications(on: Bool)
    func set(profile: ProfileData?)
    func set(state: ProfileState)
    func set(streaks: StreakData?)
    func logout(onBack:(()->Void)?)
}

class ProfilePresenter {
    
    weak var view: ProfileView?
    
    init(view: ProfileView) {
        self.view = view
    }
    
    func updateStreaks(user: User) {
        _ = ApiDataDownloader.userActivities.retrieve(user: user.id, success: {
            [weak self]
            activity in
                self?.view?.set(streaks: StreakData(userActivity: activity))
            }, error: {
                _ in
                self.view?.set(streaks: nil)
        })
    }
    
    func updateProfile() {
        if AuthInfo.shared.isAuthorized {
            if let user = AuthInfo.shared.user {
                self.view?.set(profile: ProfileData(user: user))
                self.view?.set(state: .authorized)
            } else {
                self.view?.set(state: .refreshing)
                performRequest({
                    [weak self] in
                    if let user = AuthInfo.shared.user {
                        self?.view?.set(profile: ProfileData(user: user))
                        self?.view?.set(state: .authorized)
                    } else {
                        self?.view?.set(profile: nil)
                        self?.view?.set(state: .error)
                    }
                }, error: {
                    [weak self]
                    error in
                    if error == PerformRequestError.noAccessToRefreshToken {
                        self?.view?.logout(onBack: {
                            [weak self] in
                            self?.updateProfile()
                        })
                    } else {
                        self?.view?.set(profile: nil)
                        self?.view?.set(state: .error)
                    }
                })
            }
        } else {
            self.view?.set(state: .anonymous)
        }
    }
}

enum ProfileState {
    case authorized
    case refreshing
    case error
    case anonymous
}

struct ProfileData {
    init(user: User) {
        
    }
}

struct StreakData {
    init(userActivity: UserActivity) {
        
    }
}
