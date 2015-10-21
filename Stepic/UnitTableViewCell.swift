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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithUnit(unit: Unit, delegate : PKDownloadButtonDelegate) {
        let defaultTitle = "Ooops, something got wrong"
        titleLabel.text = "\(unit.position). \(unit.lesson?.title ?? defaultTitle)"
        
        if let c = unit.lesson?.isCached {
            if c { 
                downloadButton.state = .Downloaded 
            } else { 
                downloadButton.state = .StartDownload 
            }
        } 
        
        downloadButton.tag = unit.position - 1
        downloadButton.delegate = delegate
        
        if !unit.isActive {
            titleLabel.enabled = false
            downloadButton.hidden = true
        }
    }
}
