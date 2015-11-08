//
//  SectionTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class SectionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
        
    @IBOutlet weak var downloadButton: PKDownloadButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressView.setRoundedBounds(width: 0)
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton)
        // Initialization code
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private class func getTextFromSection(section: Section) -> String {
        var text = ""
        if section.beginDate != nil { 
            text = "\nBegin date: \(section.beginDate!.getStepicFormatString())"
        }
        if section.softDeadline != nil {
            text = "\(text)\nSoft deadline: \(section.softDeadline!.getStepicFormatString())"
        }
        if section.hardDeadline != nil {
            text = "\(text)\nHard Deadline: \(section.hardDeadline!.getStepicFormatString())"
        }
        return text
    }
    
    class func heightForCellInSection(section: Section) -> CGFloat {
        let titleText = "\(section.position). \(section.title)"
        let datesText = SectionTableViewCell.getTextFromSection(section)
        return 32 + UILabel.heightForLabelWithText(titleText, lines: 0, standardFontOfSize: 14, width: UIScreen.mainScreen().bounds.width - 117) + (datesText == "" ? 0 : 8 + UILabel.heightForLabelWithText(datesText, lines: 0, standardFontOfSize: 14, width: UIScreen.mainScreen().bounds.width - 117))
    }
    
    func updateDownloadButton(section: Section) {
        if section.isCached { 
            downloadButton.state = .Downloaded 
        } else if section.isDownloading { 
            
//            print("update download button while downloading")
            downloadButton.state = .Downloading
            downloadButton.stopDownloadButton?.progress = CGFloat(section.goodProgress)
            
            section.storeProgress = {
                id, prog in
                self.downloadButton.stopDownloadButton?.progress = CGFloat(prog)
//                print("set progress = \(prog)")
            }
            
            section.storeCompletion = {
                id in
                self.downloadButton.state = .Downloaded
            }
            
        } else {
            downloadButton.state = .StartDownload
        }
    }
    
    func initWithSection(section: Section, delegate : PKDownloadButtonDelegate) {
        titleLabel.text = "\(section.position). \(section.title)"
        
        datesLabel.text = SectionTableViewCell.getTextFromSection(section)
        
        progressView.backgroundColor = UIColor.grayColor()
        if let passed = section.progress?.isPassed {
            if passed {
                progressView.backgroundColor = UIColor.stepicGreenColor()
            }
        }
                
        updateDownloadButton(section)
        
        downloadButton.tag = section.position - 1
        downloadButton.delegate = delegate
        
        if !section.isActive {
            titleLabel.enabled = false
            datesLabel.enabled = false
            downloadButton.hidden = true
        } else {
            titleLabel.enabled = true
            datesLabel.enabled = true
            downloadButton.hidden = false
        }
//        if let cr = section.beginDate?.compare(NSDate()) {
//            if cr = NSComparisonResult.OrderedDescending {
//                
//            }
//        }
    }
    
}
