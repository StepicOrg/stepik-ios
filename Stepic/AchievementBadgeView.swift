//
//  AchievementBadgeView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.06.2018.
//  Copyright © 2018 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

struct AchievementViewData {
    let id: String

    let title: String
    let description: String

    let badge: UIImage

    let completedLevel: Int
    let maxLevel: Int
    let score: Int
    let maxScore: Int

    var isLocked: Bool {
        return completedLevel == 0
    }
}

class AchievementBadgeView: UIView {
    // Gradient colors and locations for progress circle
    private static let colors = [
        UIColor(hex: 0xa9aeff),
        UIColor(hex: 0xa99cff),
        UIColor(hex: 0xa992ff),
        UIColor(hex: 0xaca5ff),
        UIColor(hex: 0xacecfe)
    ]
    private static let locations = [0.0, 0.14, 0.25, 0.425, 1.0]

    private static let relativeBadgeHeight: CGFloat = 0.83
    private static let relativeStarsHeight: CGFloat = 0.09
    private static let relativeProgressWidth: CGFloat = 0.022
    private static let relativeBadgeImagePadding: CGFloat = 0.03

    @IBOutlet weak var paddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var starsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var badgeImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var starsStackView: UIStackView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var badgeImageView: UIImageView!

    var data: AchievementViewData? {
        didSet {
            updateProgress()
        }
    }

    var onTap: (() -> Void)? {
        didSet {
            self.isUserInteractionEnabled = onTap != nil
        }
    }

    var circleViewGradientLayer: CAGradientLayer?
    var circleProgressLayer: CAShapeLayer?
    private var previousBadgeFrame: CGRect?

    override func awakeFromNib() {
        super.awakeFromNib()

        onTap = nil
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        self.addGestureRecognizer(gestureRecognizer)

        clipsToBounds = true

        addGradient()
    }

    @objc func didTap() {
        onTap?()
    }

    private func addGradient() {
        circleViewGradientLayer = CAGradientLayer(colors: AchievementBadgeView.colors, locations: AchievementBadgeView.locations, rotationAngle: 130.0)

        guard let circleViewGradientLayer = circleViewGradientLayer else {
            return
        }

        circleViewGradientLayer.opacity = 0.25
        circleView.layer.insertSublayer(circleViewGradientLayer, at: 0)
    }

    private func initViews() {
        // Auto-resize: we calculate subviews sizes based on view height
        let height = self.frame.height
        let relativePaddingHeight = 1.0 - AchievementBadgeView.relativeBadgeHeight - AchievementBadgeView.relativeStarsHeight
        let badgeHeight = AchievementBadgeView.relativeBadgeHeight * height
        paddingConstraint.constant = relativePaddingHeight * height
        circleViewHeightConstraint.constant = badgeHeight
        starsStackViewHeightConstraint.constant = AchievementBadgeView.relativeStarsHeight * height
        badgeImageViewHeightConstraint.constant = -2.0 * AchievementBadgeView.relativeBadgeImagePadding * badgeHeight
        layoutIfNeeded()

        let progressWidth = height * AchievementBadgeView.relativeProgressWidth
        let innerCircleRadius = badgeHeight * 0.5

        // Draw gradient circle
        let gradientCircleLayer = CAShapeLayer()
        gradientCircleLayer.lineWidth = progressWidth
        let bezierPath = UIBezierPath()

        bezierPath.addArc(withCenter: CGPoint(x: circleView.bounds.midX, y: circleView.bounds.midY), radius: innerCircleRadius - progressWidth, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        gradientCircleLayer.path = bezierPath.cgPath
        gradientCircleLayer.fillColor = nil
        gradientCircleLayer.strokeColor = UIColor.black.cgColor

        circleViewGradientLayer?.mask = gradientCircleLayer
    }

    private func initStageProgress(value: Float) {
        let stageProgress = max(0.0, min(value, 1.0))

        let height = self.frame.height
        let badgeHeight = AchievementBadgeView.relativeBadgeHeight * height
        let progressWidth = height * AchievementBadgeView.relativeProgressWidth

        let innerCircleRadius = badgeHeight * 0.5
        let progress = CGFloat(stageProgress) * 2.0 * .pi

        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: CGPoint(x: circleView.bounds.midX, y: circleView.bounds.midY), radius: innerCircleRadius - progressWidth, startAngle: .pi / 2, endAngle: .pi / 2 + progress, clockwise: true)

        circleProgressLayer?.removeFromSuperlayer()
        circleProgressLayer = CAShapeLayer()

        guard let circleProgressLayer = circleProgressLayer else {
            return
        }

        circleProgressLayer.path = circlePath.cgPath
        circleProgressLayer.fillColor = nil
        circleProgressLayer.strokeColor = UIColor.stepicGreen.cgColor
        circleProgressLayer.lineWidth = progressWidth

        circleView.layer.addSublayer(circleProgressLayer)
    }

    private func initLevelProgress(completedLevel: Int, maxLevel: Int) {
        let completedLevel = max(min(maxLevel, completedLevel), 0)

        for v in starsStackView.arrangedSubviews {
            starsStackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        if completedLevel != 0 {
            // Remove previous width constraint (cause it based on maxLevel)
            for c in starsStackView.constraints {
                if c.firstAttribute == .width {
                    starsStackView.removeConstraint(c)
                }
            }

            let filledCount = completedLevel
            let borderedCount = completedLevel == maxLevel ? 0 : 1
            let grayCount = maxLevel - filledCount - borderedCount

            let spaceBetweenStars = starsStackViewHeightConstraint.constant * 0.3
            starsStackView.spacing = spaceBetweenStars

            NSLayoutConstraint(item: starsStackView, attribute: .width, relatedBy: .equal, toItem: starsStackView, attribute: .height, multiplier: CGFloat(maxLevel), constant: CGFloat(maxLevel - 1) * spaceBetweenStars).isActive = true

            for _ in 0..<filledCount {
                starsStackView.addArrangedSubview(UIImageView(image: #imageLiteral(resourceName: "star-filled")))
            }

            for _ in 0..<borderedCount {
                starsStackView.addArrangedSubview(UIImageView(image: #imageLiteral(resourceName: "star-bordered")))
            }

            for _ in 0..<grayCount {
                starsStackView.addArrangedSubview(UIImageView(image: #imageLiteral(resourceName: "star-gray")))
            }
        }
    }

    private func updateProgress() {
        if let data = self.data {
            if data.isLocked {
                self.circleView.alpha = 0.3
                self.circleViewGradientLayer?.isHidden = true
            } else {
                self.circleView.alpha = 1.0
                self.circleViewGradientLayer?.isHidden = false
            }

            self.initStageProgress(value: Float(data.score) / Float(data.maxScore))
            self.badgeImageView.image = data.badge
            self.initLevelProgress(completedLevel: data.completedLevel, maxLevel: data.maxLevel)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if previousBadgeFrame != self.bounds {
            previousBadgeFrame = self.bounds

            circleViewGradientLayer?.frame = self.bounds
            initViews()

            updateProgress()
        }
    }
}
