//
//  SwitchMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class SwitchMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var blockSwitch: UISwitch!

    var block: SwitchMenuBlock?

    override func colorize() {
        super.colorize()
        self.blockSwitch.tintColor = .stepikAccent
    }

    func initWithBlock(block: SwitchMenuBlock) {
        super.initWithBlock(block: block)

        self.titleLabel.text = block.title
        self.titleLabel.textColor = block.titleColor
        self.blockSwitch.isOn = block.isOn
        self.block = block
    }

    @IBAction
    func switchChanged(_ sender: Any) {
        guard let block = self.block else {
            return
        }

        block.onSwitch?(self.blockSwitch.isOn)
        self.separator.isHidden = !block.hasSeparatorOnBottom
    }
}
