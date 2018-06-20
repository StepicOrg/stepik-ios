//
//  AchievementNotificationBannerView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

class AchievementNotificationBannerView: UIView {
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var badgeContainerView: UIView!

    var data: AchievementViewData?

    var containerViewGradient: CAGradientLayer = {
        let gradientColors = [
            UIColor(hex: 0xa9aeff),
            UIColor(hex: 0xa99cff),
            UIColor(hex: 0xa992ff),
            UIColor(hex: 0xaca5ff),
            UIColor(hex: 0xacecfe)
        ]
        let gradientLocations = [0.0, 0.14, 0.25, 0.425, 1.0]
        let gradient = CAGradientLayer(colors: gradientColors, locations: gradientLocations, rotationAngle: 130.0)
        return gradient
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        if containerViewGradient.superlayer == nil {
            badgeContainerView.layer.insertSublayer(containerViewGradient, at: 0)

            badgeImageView.image = data?.badge
        }

        containerViewGradient.frame = badgeContainerView.bounds
    }
}
