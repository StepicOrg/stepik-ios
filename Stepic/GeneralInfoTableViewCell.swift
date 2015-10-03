//
//  GeneralInfoTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

enum DisplayingInfoType {
    case Overview, Detailed
}

class GeneralInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
  
    @IBOutlet weak var joinButton: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        joinButton.setRoundedCorners(cornerRadius: 6, borderWidth: 1, borderColor: UIColor.stepicGreenColor())

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithCourse(course: Course) {
        courseNameLabel.text = course.title
    }
    

}
