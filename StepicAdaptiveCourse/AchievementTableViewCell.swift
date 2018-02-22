//
//  AchievementTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 31.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AchievementTableViewCell: UITableViewCell {

    static var reuseId = "achievementCell"

    @IBOutlet weak var cardPadView: UIView!
    @IBOutlet weak var achievementNameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var achievementInfoLabel: UILabel!
    @IBOutlet weak var progressCounterLabel: UILabel!
    @IBOutlet weak var progressChallengeLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var coverOverlayView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        colorize()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        progressChallengeLabel.isHidden = false
        progressBar.isHidden = true
        progressCounterLabel.isHidden = true

        achievementInfoLabel.text = ""
        achievementNameLabel.text = ""

        coverOverlayView.isHidden = false
    }

    func updateInfo(name: String, info: String, cover: UIImage?, isUnlocked: Bool = false, type: AchievementType = .challenge, currentProgress: Int = 0, maxProgress: Int = 1) {
        achievementNameLabel.text = name
        achievementInfoLabel.text = info

        coverImageView.image = cover

        progressBar.isHidden = type == .challenge
        progressCounterLabel.isHidden = type == .challenge
        progressChallengeLabel.isHidden = type != .challenge

        if type != .challenge && maxProgress > 0 {
            progressBar.setProgress(Float(currentProgress) / Float(maxProgress), animated: false)
            progressCounterLabel.text = "\(currentProgress) ⁄ \(maxProgress)"
        }

        if type == .challenge {
            progressChallengeLabel.text = isUnlocked ? NSLocalizedString("AchievementUnlocked", comment: "") : NSLocalizedString("AchievementLocked", comment: "")
        }

        if isUnlocked {
            coverOverlayView.isHidden = true
        }
    }

    fileprivate func colorize() {
        progressBar.trackTintColor = UIColor.mainDark.withAlphaComponent(0.3)
        progressBar.progressTintColor = UIColor.mainDark
    }
}
