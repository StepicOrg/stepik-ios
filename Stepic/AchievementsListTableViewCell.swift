//
//  AchievementsListTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AchievementsListTableViewCell: UITableViewCell {
    static let reuseId = "AchievementsListTableViewCell"

    @IBOutlet weak var badgeContainer: UIView!
    @IBOutlet weak var achievementName: UILabel!
    @IBOutlet weak var achievementDescription: UILabel!

    private var badgeView: AchievementBadgeView?

    override func layoutSubviews() {
        super.layoutSubviews()

        if #available(iOS 13.0, *), self.traitCollection.userInterfaceStyle == .dark {
            self.contentView.backgroundColor = .stepikSecondaryBackground
        } else {
            self.contentView.backgroundColor = .stepikBackground
        }

        self.achievementName.textColor = .stepikPrimaryText
        self.achievementDescription.textColor = .stepikSystemSecondaryLabel
    }

    func update(with viewData: AchievementViewData) {
        self.achievementName.text = viewData.title
        self.achievementDescription.text = viewData.description

        if self.badgeView == nil {
            let badgeView: AchievementBadgeView = AchievementBadgeView.fromNib()
            badgeView.translatesAutoresizingMaskIntoConstraints = false
            self.badgeContainer.addSubview(badgeView)
            badgeView.snp.makeConstraints { $0.edges.equalTo(badgeContainer) }
            self.badgeView = badgeView
        }

        self.badgeView?.data = viewData
    }
}
