//
//  FillBlanksTextTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class FillBlanksTextTableViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        optionLabel.numberOfLines = 0
        optionLabel.font = UIFont(name: "ArialMT", size: 16)
        optionLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        optionLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        optionLabel.textAlignment = NSTextAlignment.natural
        optionLabel.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func getHeight(htmlText text: String, width w: CGFloat) -> CGFloat {
        return max(27, UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w -  24, html: true)) + 17
    }

    func setHTMLText(_ text: String) {
        self.optionLabel.setTextWithHTMLString(text)
    }
}
