//
//  AchievementPopupViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 18.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

final class AchievementPopupViewController: UIViewController {
    enum Source: String {
        case profile
        case achievementList = "achievement-list"
        case notification
    }

    @IBOutlet weak var achievementNameLabel: UILabel!
    @IBOutlet weak var achievementDescriptionLabel: UILabel!
    @IBOutlet weak var achievementBadgeImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var shareButton: StepikButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var separatorView: UIView!

    var data: AchievementViewData?
    var canShare = true
    var source: Source = .notification

    private let analytics: Analytics = StepikAnalytics.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        self.achievementDescriptionLabel.snp.makeConstraints { $0.width.equalTo(UIScreen.main.bounds.width - 64) }

        self.shareButton.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
        self.closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)

        if let data = self.data {
            self.update(with: data)

            if !self.canShare || data.isLocked {
                self.shareButton.alpha = 0.0
            }
        }

        self.colorize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    @IBAction
    func onShareButtonClick(_ sender: Any) {
        guard let data = self.data else {
            return
        }

        self.analytics.send(
            .achievementPopupShared(source: self.source.rawValue, kind: data.id, level: data.completedLevel)
        )

        let activityViewController = UIActivityViewController(
            activityItems: [
                String(format: NSLocalizedString("AchievementsShareText", comment: ""), "\(data.title)")
            ],
            applicationActivities: nil
        )
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
        activityViewController.popoverPresentationController?.sourceView = shareButton
        self.present(activityViewController, animated: true)
    }

    @IBAction
    func onCloseButtonClick(_ sender: Any) {
        self.dismiss(animated: true)
    }

    private func update(with data: AchievementViewData) {
        self.achievementNameLabel.text = data.title
        self.achievementDescriptionLabel.text = data.description
        self.achievementBadgeImageView.image = data.badge

        if data.completedLevel == data.maxLevel {
            self.progressLabel.alpha = 0.0
        } else {
            self.progressLabel.text = String(
                format: NSLocalizedString("AchievementsNextLevel", comment: ""), "\(data.maxScore - data.score)"
            )
        }

        if data.isLocked {
            self.levelLabel.text = NSLocalizedString("AchievementsLevelNotObtained", comment: "")
        } else {
            self.levelLabel.text = String(
                format: NSLocalizedString("AchievementsLevel", comment: ""), "\(data.completedLevel)", "\(data.maxLevel)"
            )
        }
    }

    private func colorize() {
        self.view.backgroundColor = .stepikAlertBackground
        self.achievementNameLabel.textColor = .stepikPrimaryText
        self.achievementDescriptionLabel.textColor = .stepikPrimaryText
        self.separatorView.backgroundColor = .stepikSeparator
        self.levelLabel.textColor = .stepikPrimaryText
        self.progressLabel.textColor = .stepikPrimaryText
        self.closeButton.setTitleColor(.stepikPrimaryText, for: .normal)
    }
}
