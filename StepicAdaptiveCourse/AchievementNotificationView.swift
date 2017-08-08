//
//  AchievementNotificationView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AchievementNotificationView: UIView {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tapToShareLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    func updateInfo(name: String, cover: UIImage) {
        infoLabel.text = name
        coverImageView.image = cover
        
        tapToShareLabel.text = NSLocalizedString("TapToShareAchievement", comment: "")
    }

}
