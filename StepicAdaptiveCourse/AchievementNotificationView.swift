//
//  AchievementNotificationView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AchievementNotificationView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    func updateInfo(name: String, cover: UIImage) {
        nameLabel.text = NSLocalizedString("AchievementUnlockedTitle", comment: "")
        infoLabel.text = name
        coverImageView.image = cover
    }

}
