//
//  TitleTextTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 19.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class TitleTextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func heightForCellWith(title title: String, text: String) -> CGFloat {
//        Time.tick("height \(title)")
        let constrainHeight: CGFloat = 32
        let width = UIScreen.mainScreen().bounds.width - 24
        let titleHeight = UILabel.heightForLabelWithText(title, lines: 1, standardFontOfSize: 17, width: width, html : false)
        let textHeight = UILabel.heightForLabelWithText(text, lines: 0, standardFontOfSize: 13, width: width, html : true)
//        Time.tock("height \(title)")
        return constrainHeight + titleHeight + textHeight
    }
    
    func initWith(title title: String, text: String) {
//        Time.tick(title)
        titleLabel.text = title
        descriptionLabel.setTextWithHTMLString(text)
//        Time.tock(title)
    }
    
}
