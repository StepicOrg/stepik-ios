//
//  AchievementsListTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class AchievementsListTableViewCell: UITableViewCell {
    @IBOutlet weak var badgeContainer: UIView!
    @IBOutlet weak var achievementName: UILabel!
    @IBOutlet weak var achievementDescription: UILabel!

    private var badgeView: AchievementBadgeView?

    static let reuseId = "AchievementsListTableViewCell"

    func update(with viewData: AchievementViewData) {
        achievementName.text = viewData.name
        achievementDescription.text = viewData.description

        if badgeView == nil {
            let badgeView: AchievementBadgeView = AchievementBadgeView.fromNib()
            badgeView.translatesAutoresizingMaskIntoConstraints = false
            badgeContainer.addSubview(badgeView)
            badgeView.align(toView: badgeContainer)
            self.badgeView = badgeView
        }

        badgeView?.data = viewData.badgeData
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
