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
    
    @IBOutlet weak var cellContentView: UIView!
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
        
        cellContentView.layer.cornerRadius = 10
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawShadow()
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
    
    func updateInfo(name: String, info: String, cover: UIImage?, isUnlocked: Bool = false, isChallenge: Bool = true, currentProgress: Int = 0, maxProgress: Int = 1) {
        achievementNameLabel.text = name
        achievementInfoLabel.text = info
        
        coverImageView.image = cover
        
        progressBar.isHidden = isChallenge
        progressCounterLabel.isHidden = isChallenge
        progressChallengeLabel.isHidden = !isChallenge
        
        if !isChallenge && maxProgress > 0 {
            progressBar.setProgress(Float(currentProgress) / Float(maxProgress), animated: true)
            progressCounterLabel.text = "\(currentProgress) ⁄ \(maxProgress)"
        }
        
        if isChallenge {
            progressChallengeLabel.text = isUnlocked ? NSLocalizedString("AchievementUnlocked", comment: "") : NSLocalizedString("AchievementLocked", comment: "")
        }
        
        if isUnlocked {
            coverOverlayView.isHidden = true
        }
    }
    
    fileprivate func colorize() {
        progressBar.trackTintColor = StepicApplicationsInfo.adaptiveMainColor.withAlphaComponent(0.3)
        progressBar.tintColor = StepicApplicationsInfo.adaptiveMainColor
    }
    
    fileprivate func drawShadow(shouldRedraw: Bool = false) {
        if shouldRedraw {
            cellContentView.layer.shadowPath = UIBezierPath(roundedRect: cellContentView.bounds, cornerRadius: cellContentView.layer.cornerRadius).cgPath
            return
        }
        
        cellContentView.backgroundColor = .clear
        cellContentView.layer.shadowPath = UIBezierPath(roundedRect: cellContentView.bounds, cornerRadius: cellContentView.layer.cornerRadius).cgPath
        cellContentView.layer.shouldRasterize = true
        cellContentView.layer.rasterizationScale = UIScreen.main.scale
        cellContentView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cellContentView.layer.shadowOpacity = 0.2
        cellContentView.layer.shadowRadius = 2.0
        
        cardPadView.backgroundColor = .white
        cardPadView.clipsToBounds = true
        cardPadView.layer.cornerRadius = cellContentView.layer.cornerRadius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        drawShadow(shouldRedraw: true)
    }
}
