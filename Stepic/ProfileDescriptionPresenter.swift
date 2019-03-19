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
        update(shortBio: user.bio, details: user.details)
    }

    func update(with profile: Profile) {
        update(shortBio: profile.shortBio, details: profile.details)
    }

    private func update(shortBio: String, details: String) {
        let bio = shortBio.count > 0 ? shortBio : nil
        let info = details.count > 0 ? details : nil
        view?.set(shortBio: bio, info: info)
    }
}
