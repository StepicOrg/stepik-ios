//
//  PersonalDeadlineModeCollectionViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 15.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class PersonalDeadlineModeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadLabel: UILabel!

    @IBOutlet weak var modeImage: UIImageView!

    override var isHighlighted: Bool {
        didSet {
            let animationOffset: CGFloat = 2
            // Animate mode cell shrink & green on selection
            UIView.animate(withDuration: 0.1) {
                self.contentView.frame = CGRect(
                    x: self.isHighlighted ? self.contentView.frame.origin.x + animationOffset : self.contentView.frame.origin.x - animationOffset,
                    y: self.isHighlighted ? self.contentView.frame.origin.y + animationOffset : self.contentView.frame.origin.y - animationOffset,
                    width: self.isHighlighted ? self.contentView.frame.width - animationOffset * 2 : self.contentView.frame.width + animationOffset * 2,
                    height: self.isHighlighted ? self.contentView.frame.height - animationOffset * 2 : self.contentView.frame.height + animationOffset * 2
                )
                self.contentView.backgroundColor = self.isHighlighted ? .stepikLightGreen : .clear
                self.contentView.layoutSubviews()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.setRoundedCorners(cornerRadius: 8, borderWidth: 1, borderColor: .stepikSeparator)
        self.colorize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    func setup(deadlineMode: DeadlineMode) {
        let modeInfo = deadlineMode.getModeInfo()
        self.titleLabel.text = modeInfo.title
        self.loadLabel.text = "\(modeInfo.weeklyLoadHours) \(NSLocalizedString("HrsPerWeek", comment: ""))"
        self.modeImage.image = modeInfo.image
    }

    private func colorize() {
        self.contentView.layer.borderColor = UIColor.stepikSeparator.cgColor
        self.titleLabel.textColor = .stepikSystemLabel
        self.loadLabel.textColor = .stepikSystemSecondaryLabel
    }
}
