//
//  PersonalDeadlineModeCollectionViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 15.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class PersonalDeadlineModeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var loadLabel: StepikLabel!

    @IBOutlet weak var modeImage: UIImageView!

    func setup(deadlineMode: DeadlineMode) {
        let modeInfo = deadlineMode.getModeInfo()
        titleLabel.text = modeInfo.title
        loadLabel.text = "\(modeInfo.weeklyLoadHours) \(NSLocalizedString("HrsPerWeek", comment: ""))"
        modeImage.image = modeInfo.image
    }

    override var isHighlighted: Bool {
        didSet {
            let animationOffset : CGFloat = 2
            UIView.animate(withDuration: 0.1) {
                self.contentView.frame = CGRect(x: self.isHighlighted ? self.contentView.frame.origin.x + animationOffset : self.contentView.frame.origin.x - animationOffset,
                                    y: self.isHighlighted ? self.contentView.frame.origin.y + animationOffset : self.contentView.frame.origin.y - animationOffset,
                                    width: self.isHighlighted ? self.contentView.frame.width - animationOffset * 2 : self.contentView.frame.width + animationOffset * 2,
                                    height: self.isHighlighted ? self.contentView.frame.height - animationOffset * 2 : self.contentView.frame.height + animationOffset * 2)
                self.contentView.backgroundColor = self.isHighlighted ? UIColor(hex: 0xf6fcf6, alpha: 1) : UIColor.clear
                self.contentView.layoutSubviews()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.setRoundedCorners(cornerRadius: 8, borderWidth: 1, borderColor: UIColor.mainDark)
    }
}
