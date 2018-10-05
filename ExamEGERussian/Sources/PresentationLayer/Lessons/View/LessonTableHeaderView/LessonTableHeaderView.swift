//
//  LessonTableHeaderView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 25/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension LessonTableHeaderView {
    struct Appearance {
        var gradientColors: [UIColor] = []
        let gradientLocations: [Double]? = nil
        let gradientRotationAngle: CGFloat = 90.0
    }
}

final class LessonTableHeaderView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    @IBOutlet var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var subtitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var subtitleLabelBottomConstraint: NSLayoutConstraint!

    var appearance = Appearance() {
        didSet {
            updateAppearance()
        }
    }

    var layoutHeight: CGFloat {
        let titleHeight = titleLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        let subtitleHeight = subtitleLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height

        return ceil(titleHeight
            + subtitleHeight
            + titleLabelTopConstraint.constant
            + subtitleLabelTopConstraint.constant
            + subtitleLabelBottomConstraint.constant
        )
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

        titleLabel.text = nil
        subtitleLabel.text = nil

        layer.insertSublayer(gradientLayer, at: 0)
        updateAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func updateAppearance() {
        gradientLayer.colors = appearance.gradientColors.map { $0.cgColor }
        gradientLayer.applyDefaultLocations()
    }
}
