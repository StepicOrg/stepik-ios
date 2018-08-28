//
//  CardCollectionViewCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CardCollectionViewCell: UICollectionViewCell, Reusable, NibLoadable {
    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!

    let gradientLayer: CAGradientLayer = {
        CAGradientLayer(
            colors: [UIColor(hex: 0x516395), UIColor(hex: 0x4CA0AE)],
            locations: [0.0, 1.0],
            rotationAngle: 90.0
        )
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 10

        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.cornerRadius = 10

        titleLabel.textColor = .white
        bodyLabel.textColor = .white
        commentLabel.textColor = .white
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
}
