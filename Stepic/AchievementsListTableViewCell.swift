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
    private var gradient: CAGradientLayer?

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

        if viewData.isEmpty {
            let gradient = CAGradientLayer(colors: [UIColor(hex: 0x795BA3), UIColor.black], rotationAngle: 105.0)
            contentView.layer.insertSublayer(gradient, at: 0)
            self.gradient = gradient

            achievementName.textColor = UIColor.white
            achievementDescription.textColor = UIColor.white.withAlphaComponent(0.5)
        } else {
            achievementName.textColor = UIColor.mainText
            achievementDescription.textColor = UIColor.mainText
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient?.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        gradient?.removeFromSuperlayer()
    }
}
