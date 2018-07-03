//
//  TransitionMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

class TransitionMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var subtitleLabel: StepikLabel!

    var titleBottomSpaceConstraint: Constraint?
    var subtitleBottomSpaceConstraint: Constraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.snp.makeConstraints { make -> Void in
            titleBottomSpaceConstraint = make.bottom.equalTo(self.contentView).offset(-25).constraint
        }
        subtitleLabel.snp.makeConstraints { make -> Void in
            subtitleBottomSpaceConstraint = make.bottom.equalTo(self.contentView).offset(-25).constraint
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithBlock(block: TransitionMenuBlock) {
        super.initWithBlock(block: block)
        titleLabel.text = block.title
        titleLabel.textColor = block.titleColor
        if let subtitle = block.subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
            titleBottomSpaceConstraint?.deactivate()
            subtitleBottomSpaceConstraint?.activate()
        } else {
            subtitleBottomSpaceConstraint?.deactivate()
            titleBottomSpaceConstraint?.activate()
            subtitleLabel.isHidden = true
        }
    }

}
