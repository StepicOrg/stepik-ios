//
//  TextChoiceQuizTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox

class TextChoiceQuizTableViewCell: UITableViewCell {

    @IBOutlet weak var choiceLabel: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!

    override func awakeFromNib() {
        super.awakeFromNib()

        choiceLabel.numberOfLines = 0
        choiceLabel.font = UIFont(name: "ArialMT", size: 16)
        choiceLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        choiceLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        choiceLabel.textAlignment = NSTextAlignment.natural
        
        checkBox.onAnimationType = .fill
        checkBox.animationDuration = 0.3
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getHeightForText(text: String, width w: CGFloat) -> Int {
        return max(27, Int(UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w - 52))) + 17
    }
    
    func setHTMLText(_ text: String) {
        self.choiceLabel.setTextWithHTMLString(text)
    }

}
