//
//  ContentExpandableMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

class ContentExpandableMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var arrowButton: UIButton!

    var bottomTitleConstraint: NSLayoutConstraint?

    var block: ContentExpandableMenuBlock?
    var updateTableHeightBlock: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func initWithBlock(block: MenuBlock) {
        super.initWithBlock(block: block)
        titleLabel.text = block.title

        if let block = block as? ContentExpandableMenuBlock {
            self.block = block
            if let contentView = block.contentView {
                container.addSubview(contentView)
                contentView.snp.makeConstraints { $0.edges.equalTo(container) }
                layoutIfNeeded()
            }

            if block.isExpanded {
                expand(shouldAnimate: false)
            } else {
                shrink(shouldAnimate: false)
            }
        }
    }

    @IBAction func arrowButtonPressed(_ sender: UIButton) {
        expandPressed()
    }

    func expandPressed() {
        guard let block = block else {
            return
        }

        block.onExpanded?(!block.isExpanded)
        if block.isExpanded {
            expand()
        } else {
            shrink()
        }
        layoutIfNeeded()
        updateTableHeightBlock?()
    }

    func expand(shouldAnimate: Bool = true) {
        bottomTitleConstraint?.isActive = false
        container.isHidden = false

        let animationBlock: () -> Void = { [weak self] in
            self?.arrowButton.transform = CGAffineTransform.identity
        }
        if shouldAnimate {
            UIView.animate(withDuration: 0.3, animations: animationBlock)
        } else {
            animationBlock()
        }
    }

    func shrink(shouldAnimate: Bool = true) {
        container.isHidden = true
        if bottomTitleConstraint == nil {
            titleLabel.snp.makeConstraints { make -> Void in
                bottomTitleConstraint = make.bottom.equalTo(self.contentView).offset(-26)
            }
        } else {
            bottomTitleConstraint?.isActive = true
        }

        let animationBlock: () -> Void = { [weak self] in
            self?.arrowButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        if shouldAnimate {
            UIView.animate(withDuration: 0.3, animations: animationBlock)
        } else {
            animationBlock()
        }
    }

}
