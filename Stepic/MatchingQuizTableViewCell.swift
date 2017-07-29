//
//  MatchingQuizTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MatchingQuizTableViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        optionLabel.numberOfLines = 0
        optionLabel.font = UIFont(name: "ArialMT", size: 16)
        optionLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        optionLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        optionLabel.textAlignment = NSTextAlignment.natural

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    class func getHeightForText(text: String, sortable: Bool, width w: CGFloat) -> CGFloat {
        return max(27, UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w - (sortable ? 70 : 24))) + 17
    }
    
    func setHTMLText(_ text: String) {
        self.optionLabel.setTextWithHTMLString(text)
    }
    
}
