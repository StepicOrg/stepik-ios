//
//  TransitionMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class TransitionMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var subtitleLabel: StepikLabel!

    var titleBottomSpaceConstraint: NSLayoutConstraint?
    var subtitleBottomSpaceConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleBottomSpaceConstraint = titleLabel.alignBottomEdge(with: self.contentView, predicate: "-25").first as? NSLayoutConstraint
        subtitleBottomSpaceConstraint = subtitleLabel.alignBottomEdge(with: self.contentView, predicate: "-25").first as? NSLayoutConstraint
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithBlock(block: TransitionMenuBlock) {
        super.initWithBlock(block: block)
        titleLabel.text = block.title
        titleLabel.textColor = titleColor
        if let subtitle = block.subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
            titleBottomSpaceConstraint?.isActive = false
            subtitleBottomSpaceConstraint?.isActive = true
        } else {
            subtitleBottomSpaceConstraint?.isActive = false
            titleBottomSpaceConstraint?.isActive = true
            subtitleLabel.isHidden = true
        }
    }

}
