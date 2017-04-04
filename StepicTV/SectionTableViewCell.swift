//
//  SectionTableViewCell.swift
//  Stepic
//
//  Created by Anton Kondrashov on 24/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.setRoundedBounds(width: 0)
    }
    
    fileprivate class func getTextFromSection(_ section: Section) -> String {
        var text = ""
        if section.beginDate != nil {
            text = "\n\(NSLocalizedString("BeginDate", comment: "")): \(section.beginDate!.getStepicFormatString())"
        }
        if section.softDeadline != nil {
            text = "\(text)\n\(NSLocalizedString("SoftDeadline", comment: "")): \(section.softDeadline!.getStepicFormatString())"
        }
        if section.hardDeadline != nil {
            text = "\(text)\n\(NSLocalizedString("HardDeadline", comment: "")): \(section.hardDeadline!.getStepicFormatString())"
        }
        return text
    }
    
    class func heightForCellInSection(_ section: Section) -> CGFloat {
        let titleText = "\(section.position). \(section.title)"
        let datesText = SectionTableViewCell.getTextFromSection(section)
        return 32 + UILabel.heightForLabelWithText(titleText, lines: 0, standardFontOfSize: 14, width: UIScreen.main.bounds.width - 117) + (datesText == "" ? 0 : 8 + UILabel.heightForLabelWithText(datesText, lines: 0, standardFontOfSize: 14, width: UIScreen.main.bounds.width - 117))
    }
    
    func initWithSection(_ section: Section) {
        titleLabel.text = "\(section.position). \(section.title)"
        
        datesLabel.text = SectionTableViewCell.getTextFromSection(section)
        
        progressView.backgroundColor = UIColor.gray
        if let passed = section.progress?.isPassed {
            if passed {
                progressView.backgroundColor = UIColor.stepicGreenColor()
            }
        }
        
        if !section.isActive && section.testSectionAction == nil {
            titleLabel.isEnabled = false
            datesLabel.isEnabled = false
        } else {
            titleLabel.isEnabled = true
            datesLabel.isEnabled = true
        }
    }
    
}
