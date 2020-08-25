//
//  TransitionMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

final class TransitionMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var subtitleLabel: StepikLabel!

    var titleBottomSpaceConstraint: Constraint?
    var subtitleBottomSpaceConstraint: Constraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.snp.makeConstraints { make in
            self.titleBottomSpaceConstraint = make.bottom.equalTo(self.contentView).offset(-25).constraint
        }

        self.subtitleLabel.snp.makeConstraints { make in
            self.subtitleBottomSpaceConstraint = make.bottom.equalTo(self.contentView).offset(-25).constraint
        }
    }

    func initWithBlock(block: TransitionMenuBlock) {
        super.initWithBlock(block: block)

        self.titleLabel.text = block.title
        self.titleLabel.textColor = block.titleColor

        if let subtitle = block.subtitle {
            self.subtitleLabel.text = subtitle
            self.subtitleLabel.isHidden = false
            self.titleBottomSpaceConstraint?.deactivate()
            self.subtitleBottomSpaceConstraint?.activate()
        } else {
            self.subtitleBottomSpaceConstraint?.deactivate()
            self.titleBottomSpaceConstraint?.activate()
            self.subtitleLabel.isHidden = true
        }
    }
}
