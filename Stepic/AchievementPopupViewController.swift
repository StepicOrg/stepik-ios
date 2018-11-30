//
//  AchievementPopupViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 18.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class AchievementPopupViewController: UIViewController {
    @IBOutlet weak var achievementNameLabel: UILabel!
    @IBOutlet weak var achievementDescriptionLabel: UILabel!
    @IBOutlet weak var achievementBadgeImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var shareButton: StepikButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var separatorView: UIView!

    var widthConstraint: NSLayoutConstraint?

    var data: AchievementViewData?
    var canShare: Bool = true
    var source: Source = .notification

    @IBAction func onShareButtonClick(_ sender: Any) {
        guard let data = data else {
            return
        }

        AmplitudeAnalyticsEvents.Achievements.popupShared(
            source: self.source.rawValue, kind: data.id, level: data.completedLevel
        ).send()

        let activityVC = UIActivityViewController(activityItems: [String(format: NSLocalizedString("AchievementsShareText", comment: ""), "\(data.title)")], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop]
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }

    @IBAction func onCloseButtonClick(_ sender: Any) {
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        achievementDescriptionLabel.snp.makeConstraints { $0.width.equalTo(UIScreen.main.bounds.width - 64) }

        shareButton.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
        closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)

        if let data = data {
            update(with: data)

            if !canShare || data.isLocked {
                shareButton.alpha = 0.0
            }
        }
    }

    private func update(with data: AchievementViewData) {
        self.achievementNameLabel.text = data.title
        self.achievementDescriptionLabel.text = data.description
        self.achievementBadgeImageView.image = data.badge

        if data.completedLevel == data.maxLevel {
            self.progressLabel.alpha = 0.0
        } else if let maxScore = data.maxScore, let score = data.score {
            self.progressLabel.text = String(format: NSLocalizedString("AchievementsNextLevel", comment: ""), "\(maxScore - score)")
        }

        if data.isLocked {
            self.levelLabel.text = NSLocalizedString("AchievementsLevelNotObtained", comment: "")
        } else if let completedLevel = data.completedLevel, let maxLevel = data.maxLevel {
            self.levelLabel.text = String(format: NSLocalizedString("AchievementsLevel", comment: ""), "\(completedLevel)", "\(maxLevel)")
        } else {
            self.levelLabel.alpha = 0.0
        }

        self.separatorView.alpha = self.progressLabel.alpha == 0
            && self.levelLabel.alpha == 0 ? 0 : 1
    }

    enum Source: String {
        case profile
        case achievementList = "achievement-list"
        case notification
    }
}
