//
//  LearningTableViewCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension LearningTableViewCell {
    struct Appearance {
        let cornerRadius: CGFloat = 10.0
        var gradientColors: [UIColor] = []
        let gradientLocations: [Double]? = nil
        let gradientRotationAngle: CGFloat = 90.0
        let sectionInset: CGFloat = 20.0
        let minimumItemSpacing: CGFloat = 10.0
    }
}

final class LearningTableViewCell: UITableViewCell, Reusable, NibLoadable {
    @IBOutlet var containerView: UIView!
    @IBOutlet var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet var containerBottomConstraint: NSLayoutConstraint!

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var timeToCompleteLabel: UILabel!
    @IBOutlet var timeToCompleteImageView: UIImageView!
    @IBOutlet var progressImageView: UIImageView!
    @IBOutlet var progressLabel: UILabel!

    var appearance = Appearance() {
        didSet {
            updateAppearance()
        }
    }

    private lazy var gradientLayer: CAGradientLayer = {
        CAGradientLayer(
            colors: appearance.gradientColors,
            locations: appearance.gradientLocations,
            rotationAngle: appearance.gradientRotationAngle
        )
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        containerView.backgroundColor = .clear
        containerView.layer.insertSublayer(gradientLayer, at: 0)

        setupImageView(timeToCompleteImageView, progressImageView)
        updateAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutGradientLayer()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        headerLabel.text = nil
        descriptionLabel.text = nil
        timeToCompleteLabel.text = nil
        progressLabel.text = nil
    }

    private func setupImageView(_ imageViews: UIImageView...) {
        imageViews.forEach {
            $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = .white
        }
    }

    private func updateAppearance() {
        containerView.layer.cornerRadius = appearance.cornerRadius
        gradientLayer.cornerRadius = appearance.cornerRadius
        gradientLayer.colors = appearance.gradientColors.map { $0.cgColor }
        gradientLayer.applyDefaultLocations()
    }

    private func layoutGradientLayer() {
        // We dynamically change the size of the views, the subviews need to
        // update their values accordingly.
        containerView.layoutIfNeeded()
        gradientLayer.frame = containerView.bounds
    }
}
