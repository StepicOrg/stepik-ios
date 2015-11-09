//
//  UnitTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class UnitTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var downloadButton: PKDownloadButton!
    @IBOutlet weak var progressView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton)
        progressView.setRoundedBounds(width: 0)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func heightForCellWithUnit(unit: Unit) -> CGFloat {
        let defaultTitle = "Ooops, something got wrong"
        let text = "\(unit.position). \(unit.lesson?.title ?? defaultTitle)"
        return 32 + UILabel.heightForLabelWithText(text, lines: 0, standardFontOfSize: 14, width: UIScreen.mainScreen().bounds.width - 80)
        
    }
    
    func initWithUnit(unit: Unit, delegate : PKDownloadButtonDelegate) {
        let defaultTitle = "Ooops, something got wrong"
        titleLabel.text = "\(unit.position). \(unit.lesson?.title ?? defaultTitle)"
        
        if let c = unit.lesson?.isCached {
            if c { 
                downloadButton.state = .Downloaded 
            } else if unit.lesson!.isDownloading { 
                
                downloadButton.state = .Downloading
                downloadButton.stopDownloadButton?.progress = CGFloat(unit.lesson!.totalProgress)
                
                unit.lesson?.storeProgress = {
                    id, prog in
                    self.downloadButton.stopDownloadButton?.progress = CGFloat(prog)
//                    print("lesson store progress")
                }
                
                unit.lesson?.storeCompletion = {
                    id in
                    self.downloadButton.state = .Downloaded
                    CoreDataHelper.instance.save()
                }
                
                
            } else {
                downloadButton.state = .StartDownload
            }
        } 
        
        downloadButton.tag = unit.position - 1
        downloadButton.delegate = delegate
        
        progressView.backgroundColor = UIColor.grayColor()
        if let passed = unit.progress?.isPassed {
            if passed {
                progressView.backgroundColor = UIColor.stepicGreenColor()
            }
        }
        
        if !unit.isActive {
            titleLabel.enabled = false
            downloadButton.hidden = true
        }
    }
}
