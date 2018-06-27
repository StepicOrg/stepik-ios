//
//  ContentMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class ContentMenuBlockTableViewCell: MenuBlockTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var container: UIView!

    var onButtonClickAction: (() -> Void)?

    @IBAction func onActionButtonClick(_ sender: Any) {
        onButtonClickAction?()
    }

    override func initWithBlock(block: MenuBlock) {
        super.initWithBlock(block: block)
        titleLabel.text = block.title

        if let block = block as? ContentMenuBlock {
            actionButton.setTitle(block.buttonTitle, for: .normal)
            onButtonClickAction = block.onButtonClick

            if let contentView = block.contentView {
                container.addSubview(contentView)
                contentView.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: container)
                layoutIfNeeded()
            }
        }
    }

}
