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
    func setProfile(profile: ProfileData)
    func presentStreakData(streak: StreakData)
}

class ProfilePresenter {
    
}

struct ProfileData {
    
}

struct StreakData {
    
}
