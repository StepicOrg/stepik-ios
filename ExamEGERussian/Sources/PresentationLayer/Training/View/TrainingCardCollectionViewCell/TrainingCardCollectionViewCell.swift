//
//  TrainingCardCollectionViewCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension TrainingCardCollectionViewCell {
    struct Appearance {
        let cornerRadius: CGFloat = 10.0
        let textColor = UIColor.white
        var gradientColors: [UIColor] = []
        let gradientLocations: [Double]? = nil
        let gradientRotationAngle: CGFloat = 90.0
    }
}

final class TrainingCardCollectionViewCell: UICollectionViewCell, Reusable, NibLoadable {
    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!

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

        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = appearance.cornerRadius

        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.cornerRadius = appearance.cornerRadius

        titleLabel.textColor = appearance.textColor
        bodyLabel.textColor = appearance.textColor
        commentLabel.textColor = appearance.textColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        bodyLabel.text = nil
        commentLabel.text = nil
    }

    private func updateAppearance() {
        gradientLayer.colors = appearance.gradientColors.map { $0.cgColor }
        gradientLayer.applyDefaultLocations()
    }
}
