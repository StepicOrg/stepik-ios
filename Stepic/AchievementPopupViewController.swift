//
//  AchievementPopupViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 18.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class ABAchievementPopupViewController: AchievementPopupViewController {
    var titleText: String? {
        didSet {
            self.achievementNameLabel.text = self.titleText
        }
    }

    var descriptionText: String? {
        didSet {
            self.achievementDescriptionLabel.text = self.descriptionText
        }
    }

    var badgeImage: UIImage? {
        didSet {
            self.achievementBadgeImageView.image = self.badgeImage
        }
    }

    var kind: AchievementKind?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.shareButton.alpha = 1
        self.levelLabel.text = ""
        self.progressLabel.text = ""
    }

    override func onShareButtonClick(_ sender: Any) {
        if let kind = self.kind {
            AmplitudeAnalyticsEvents.Achievements.popupSharePressed(
                source: self.source.rawValue, kind: kind
            ).send()
        }

        let activityVC = UIActivityViewController(
            activityItems: [
                String(format: NSLocalizedString("AchievementsShareText", comment: ""), "\(self.titleText ?? "")")
            ],
            applicationActivities: nil
        )
        activityVC.excludedActivityTypes = [UIActivityType.airDrop]
        activityVC.popoverPresentationController?.sourceView = shareButton

        self.present(activityVC, animated: true)
    }
}

class AchievementPopupViewController: UIViewController {
    @IBOutlet weak var achievementNameLabel: UILabel!
    @IBOutlet weak var achievementDescriptionLabel: UILabel!
    @IBOutlet weak var achievementBadgeImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var shareButton: StepikButton!
    @IBOutlet weak var closeButton: UIButton!

    var widthConstraint: NSLayoutConstraint?

    var data: AchievementViewData?
    var canShare: Bool = true
    var source: Source = .notification

    @IBAction func onShareButtonClick(_ sender: Any) {
        guard let data = data else {
            return
        }

        AmplitudeAnalyticsEvents.Achievements.popupSharePressed(
            source: self.source.rawValue, kind: data.kind, level: data.completedLevel
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

    enum Source: String {
        case profile
        case achievementList = "achievement-list"
        case notification
    }
}
