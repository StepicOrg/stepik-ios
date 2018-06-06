//
//  ProfileAchievementsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol ProfileAchievementsView: class {

}

class ProfileAchievementsPresenter {
    weak var view: ProfileAchievementsView?

    init(view: ProfileAchievementsView) {
        self.view = view
    }
}
