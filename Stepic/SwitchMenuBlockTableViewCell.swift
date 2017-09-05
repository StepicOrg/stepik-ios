//
//  SwitchMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SwitchMenuBlockTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var blockSwitch: UISwitch!

    var block: SwitchMenuBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithBlock(block: SwitchMenuBlock) {
        titleLabel.text = block.title
        titleLabel.textColor = block.titleColor
        blockSwitch.isOn = block.isOn
        self.block = block
    }

    @IBAction func switchChanged(_ sender: Any) {
        block?.onSwitch?(blockSwitch.isOn)
    }
}
