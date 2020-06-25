//
//  SocialAuthCollectionViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class SocialAuthCollectionViewCell: UICollectionViewCell {
    enum Appearance {
        static let shadowColor = UIColor.dynamic(light: UIColor(hex6: 0xBBBBBB), dark: .clear)
        static let backgroundColor = UIColor.dynamic(
            light: .stepikBackground,
            dark: .stepikSecondaryBackground
        )
        static let appleBackgroundColor = UIColor.dynamic(light: .black, dark: .white)
    }

    static let reuseId = "socialAuthCell"

    @IBOutlet weak var imageView: UIImageView!

    var socialProviderName: String? {
        didSet {
            self.colorize()
        }
    }

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
        self.layer.shadowColor = Appearance.shadowColor.cgColor
        self.contentView.backgroundColor = self.socialProviderName?.lowercased() == "apple"
            ? Appearance.appleBackgroundColor
            : Appearance.backgroundColor
    }
}
