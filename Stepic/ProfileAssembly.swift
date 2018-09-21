//
//  ProfileAssembly.swift
//  Stepic
//
//  Created by Ostrenkiy on 15.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class ProfileAssembly: Assembly {
    var userID: Int

    init(userID: Int) {
        self.userID = userID
    }

    func makeModule() -> UIViewController {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "ProfileViewController", storyboardName: "Profile") as? ProfileViewController else {
            return UIViewController()
        }

        vc.otherUserId = userID
        return vc
    }
}
