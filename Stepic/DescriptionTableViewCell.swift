//
//  DescriptionTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithCourse(course: Course) {
        descriptionLabel.setTextWithHTMLString(course.courseDescription)
    }
    
    class func heightForCourse(course: Course) -> CGFloat {
        return 32 + UILabel.heightForLabelWithText(course.courseDescription, lines: 0, standardFontOfSize: 12, width: UIScreen.mainScreen().bounds.width - 32, html : true)
    }
}
