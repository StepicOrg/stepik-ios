//
//  ContentMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

final class ContentMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var container: UIView!

    var onButtonClickAction: (() -> Void)?

    override func initWithBlock(block: MenuBlock) {
        super.initWithBlock(block: block)

        self.titleLabel.text = block.title

        if let block = block as? ContentMenuBlock {
            self.actionButton.setTitle(block.buttonTitle, for: .normal)
            self.onButtonClickAction = block.onButtonClick

            if let contentView = block.contentView {
                self.container.addSubview(contentView)
                contentView.snp.makeConstraints { $0.edges.equalTo(container) }
                self.layoutIfNeeded()
            }
        }
    }

    override func colorize() {
        super.colorize()

        self.titleLabel.textColor = .stepikPrimaryText
        self.actionButton.setTitleColor(.stepikSystemSecondaryText, for: .normal)
    }

    @IBAction
    func onActionButtonClick(_ sender: Any) {
        self.onButtonClickAction?()
    }
}
