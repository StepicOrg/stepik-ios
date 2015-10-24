//
//  SectionTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class SectionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var beginDateLabel: UILabel!
    @IBOutlet weak var softDeadlineLabel: UILabel!
    @IBOutlet weak var hardDeadlineLabel: UILabel!
        
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithSection(section: Section) {
        titleLabel.text = "\(section.position). \(section.title)"
        if section.beginDate != nil { 
            beginDateLabel.text = "Begin date: \(section.beginDate!.getStepicFormatString())"
        }
        if section.softDeadline != nil {
            softDeadlineLabel.text = "Soft deadline: \(section.softDeadline!.getStepicFormatString())"
        }
        if section.hardDeadline != nil {
            hardDeadlineLabel.text = "Hard Deadline: \(section.hardDeadline!.getStepicFormatString())"
        }
        
        if !section.isActive {
            titleLabel.enabled = false
            beginDateLabel.enabled = false
            softDeadlineLabel.enabled = false
            hardDeadlineLabel.enabled = false
        } else {
            titleLabel.enabled = true
            beginDateLabel.enabled = true
            softDeadlineLabel.enabled = true
            hardDeadlineLabel.enabled = true
        }
//        if let cr = section.beginDate?.compare(NSDate()) {
//            if cr = NSComparisonResult.OrderedDescending {
//                
//            }
//        }
    }
    
}
