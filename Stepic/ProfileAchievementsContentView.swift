//
//  ProfileAchievementsContentView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class ProfileAchievementsContentView: UIView, ProfileAchievementsView {
    var isInit: Bool = false

    override func layoutSubviews() {
        super.layoutSubviews()

        if isInit {
            return
        }

        isInit = true
        let stackView = UIView()

        addSubview(stackView)
        stackView.alignLeading("24", trailing: "-24", toView: self)
        stackView.alignTop("0", bottom: "0", toView: self)
        stackView.constrainHeight("80")
    }
}
