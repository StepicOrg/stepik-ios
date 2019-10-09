//
//  ProfileAssembly.swift
//  Stepic
//
//  Created by Ostrenkiy on 15.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ProfileAssembly: Assembly {
    private let userID: User.IdType

    init(userID: User.IdType) {
        self.userID = userID
    }

    func makeModule() -> UIViewController {
        guard let viewController = ControllerHelper.instantiateViewController(
            identifier: "ProfileViewController",
            storyboardName: "Profile"
        ) as? ProfileViewController else {
            fatalError("Failed to initialize ProfileViewController")
        }

        viewController.otherUserId = userID

        return viewController
    }
}
