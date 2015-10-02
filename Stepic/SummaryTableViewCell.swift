//
//  SummaryTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var summaryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithCourse(course: Course) {
        summaryLabel.setTextWithHTMLString(course.summary)
    }
    
    class func heightForCourse(course: Course) -> CGFloat {
        return 16 + UILabel.heightForLabelWithText(course.summary, lines: 0, standardFontOfSize: 12, width: UIScreen.mainScreen().bounds.width - 16)
    }
}
