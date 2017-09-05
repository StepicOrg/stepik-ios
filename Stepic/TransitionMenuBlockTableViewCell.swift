//
//  TransitionMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class TransitionMenuBlockTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    var titleBottomSpaceConstraint: NSLayoutConstraint?
    var subtitleBottomSpaceConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleBottomSpaceConstraint = titleLabel.alignBottomEdge(with: self.contentView, predicate: "-12").first as? NSLayoutConstraint
        subtitleBottomSpaceConstraint = subtitleLabel.alignBottomEdge(with: self.contentView, predicate: "-12").first as? NSLayoutConstraint
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithBlock(block: TransitionMenuBlock) {
        titleLabel.text = block.title
        titleLabel.textColor = block.titleColor
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
