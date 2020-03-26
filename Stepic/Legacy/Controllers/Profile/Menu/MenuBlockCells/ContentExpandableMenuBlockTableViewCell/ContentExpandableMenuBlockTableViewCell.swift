//
//  ContentExpandableMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

final class ContentExpandableMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var arrowButton: UIButton!

    var bottomTitleConstraint: Constraint?

    var block: ContentExpandableMenuBlock?
    var updateTableHeightBlock: (() -> Void)?

    override func initWithBlock(block: MenuBlock) {
        super.initWithBlock(block: block)

        self.titleLabel.text = block.title

        if let block = block as? ContentExpandableMenuBlock {
            self.block = block

            if let contentView = block.contentView {
                self.container.addSubview(contentView)
                contentView.snp.makeConstraints { $0.edges.equalTo(container) }
                self.layoutIfNeeded()
            }

            if block.isExpanded {
                self.expand(shouldAnimate: false)
            } else {
                self.shrink(shouldAnimate: false)
            }
        }
    }

    @IBAction
    func arrowButtonPressed(_ sender: UIButton) {
        self.expandPressed()
    }

    func expandPressed() {
        guard let block = self.block else {
            return
        }

        block.onExpanded?(!block.isExpanded)

        if block.isExpanded {
            self.expand()
        } else {
            self.shrink()
        }

        self.layoutIfNeeded()
        self.updateTableHeightBlock?()
    }

    func expand(shouldAnimate: Bool = true) {
        self.bottomTitleConstraint?.deactivate()
        self.container.isHidden = false

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
        self.container.isHidden = true

        if self.bottomTitleConstraint == nil {
            self.titleLabel.snp.makeConstraints { make in
                self.bottomTitleConstraint = make.bottom.equalTo(self.contentView).offset(-26).constraint
            }
        } else {
            self.bottomTitleConstraint?.activate()
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
