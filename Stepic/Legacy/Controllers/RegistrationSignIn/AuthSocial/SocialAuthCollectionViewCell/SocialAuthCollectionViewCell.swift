//
//  SocialAuthCollectionViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class SocialAuthCollectionViewCell: UICollectionViewCell {
    static let reuseId = "socialAuthCell"

    @IBOutlet weak var imageView: UIImageView!

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.alpha = 0.3
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 1.0
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = false

        self.contentView.layer.cornerRadius = layer.cornerRadius
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor(hex6: 0xBBBBBB).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowRadius = 1.7
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.contentView.layer.cornerRadius
        ).cgPath

        self.colorize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    private func colorize() {
        if #available(iOS 13.0, *), self.traitCollection.userInterfaceStyle == .dark {
            self.contentView.backgroundColor = UIColor.stepikSecondaryBackground.withAlphaComponent(0.1)
        } else {
            self.contentView.backgroundColor = .stepikBackground
        }
    }
}
