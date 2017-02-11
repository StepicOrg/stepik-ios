//
//  FillBlanksTextTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class FillBlanksTextTableViewCell: UITableViewCell {

    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textLabel.numberOfLines = 0
        textLabel.font = UIFont(name: "ArialMT", size: 16)
        textLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        textLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        textLabel.textAlignment = NSTextAlignment.natural
        textLabel.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getHeight(htmlText: String, width w: CGFloat) -> CGFloat {
        return max(27, UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w -  24)) + 17
    }
}
