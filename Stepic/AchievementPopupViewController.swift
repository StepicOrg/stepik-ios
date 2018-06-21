//
//  AchievementPopupViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 18.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class AchievementPopupViewController: UIViewController {
    @IBOutlet weak var achievementNameLabel: UILabel!
    @IBOutlet weak var achievementDescriptionLabel: UILabel!
    @IBOutlet weak var achievementBadgeImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!

    @IBOutlet weak var shareButton: StepikButton!
    @IBOutlet weak var closeButton: UIButton!

    var data: AchievementViewData?

    @IBAction func onShareButtonClick(_ sender: Any) {
    }

    @IBAction func onCloseButtonClick(_ sender: Any) {
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        shareButton.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
        closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)

        if let data = data {
            update(with: data)
        }
    }

    private func update(with data: AchievementViewData) {
        achievementNameLabel.text = data.title
        achievementDescriptionLabel.text = data.description
        achievementBadgeImageView.image = data.badge

        if data.completedLevel == data.maxLevel {
            progressLabel.alpha = 0.0
        } else {
            progressLabel.text = String(format: NSLocalizedString("AchievementsNextLevel", comment: ""), "\(data.maxScore - data.score)")
        }

        if data.isLocked {
            levelLabel.text = NSLocalizedString("AchievementsLevelNotObtained", comment: "")
        } else {
            levelLabel.text = String(format: NSLocalizedString("AchievementsLevel", comment: ""), "\(data.completedLevel)", "\(data.maxLevel)")
        }
    }
}
