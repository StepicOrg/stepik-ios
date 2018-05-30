//
//  ProfileDescriptionPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol ProfileDescriptionView: class {
    func set(shortBio: String?, info: String?)
}

class ProfileDescriptionPresenter {
    weak var view: ProfileDescriptionView?

    init(view: ProfileDescriptionView) {
        self.view = view
    }

    func update(with user: User) {
        let bio = user.bio.count > 0 ? user.bio : nil
        let info = user.details.count > 0 ? user.details : nil
        view?.set(shortBio: bio, info: info)
    }
}
