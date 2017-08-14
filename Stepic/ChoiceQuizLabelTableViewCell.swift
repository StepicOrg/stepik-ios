//
//  ChoiceQuizLabelTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox
import FLKAutoLayout

class ChoiceQuizLabelTableViewCell: ChoiceQuizTableViewCell {

    var choiceLabel: UILabel! = UILabel()

    override var reuseIdentifier: String? {
        return "ChoiceQuizLabelTableViewCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        let x = NSBundle.mainBundle().loadNibNamed("ChoiceQuizTableViewCell", owner: self, options: nil)[0]
//        print(x)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        choiceLabel.numberOfLines = 0
        choiceLabel.font = UIFont(name: "ArialMT", size: 16)
        choiceLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        choiceLabel.baselineAdjustment = UIBaselineAdjustment.AlignBaselines
        choiceLabel.textAlignment = NSTextAlignment.Natural
//        textContainerView.addSubview(choiceLabel)
//        choiceLabel.alignToView(textContainerView)
//        print(choiceLabel.text)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    override func setHTMLText(text: String) -> (Void -> Int) {
        choiceLabel.setTextWithHTMLString(text)
        return {
            return max(27, Int(UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: UIScreen.mainScreen().bounds.width - 60))) + 17
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
