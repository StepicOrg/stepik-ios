//
//  ChoiceQuizLabelTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox

class ChoiceQuizLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var choiceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.onAnimationType = .Fill
        checkBox.animationDuration = 0.3
        contentView.backgroundColor = UIColor.clearColor()
        // Initialization code
    }

    static func heightForCellWithText(text: String) -> Int {
        return max(27, Int(UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: UIScreen.mainScreen().bounds.width - 60))) + 17
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
