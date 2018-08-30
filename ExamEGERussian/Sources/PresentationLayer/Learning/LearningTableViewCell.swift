//
//  LearningTableViewCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class LearningTableViewCell: UITableViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var timeToCompleteLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!

    let gradientLayer: CAGradientLayer = {
        CAGradientLayer(
            colors: [UIColor(hex: 0x516395), UIColor(hex: 0x4CA0AE)],
            locations: [0.0, 1.0],
            rotationAngle: 90.0
        )
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 10
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.cornerRadius = 10
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutGradientLayer()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

//        headerLabel.text = nil
//        descriptionLabel.text = nil
//        timeToCompleteLabel.text = nil
//        progressLabel.text = nil
    }

    private func layoutGradientLayer() {
        containerView.layoutIfNeeded()
        gradientLayer.frame = containerView.bounds
    }
}
