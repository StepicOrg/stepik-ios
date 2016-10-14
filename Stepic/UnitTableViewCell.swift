//
//  UnitTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton
import SDWebImage

class UnitTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var downloadButton: PKDownloadButton!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var scoreProgressView: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton)
//        progressView.setRoundedBounds(width: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func heightForCellWithUnit(_ unit: Unit) -> CGFloat {
        let defaultTitle = "Ooops, something got wrong"
        let text = "\(unit.position). \(unit.lesson?.title ?? defaultTitle)"
        return 50 + UILabel.heightForLabelWithText(text, lines: 0, standardFontOfSize: 14, width: UIScreen.main.bounds.width - 129)
        
    }
    
    func updateDownloadButton(_ unit: Unit) {
        if let lesson = unit.lesson {
            if lesson.isCached { 
                downloadButton.state = .downloaded 
            } else if lesson.isDownloading { 
                print("entered is downloading")
                downloadButton.state = .downloading
                downloadButton.stopDownloadButton?.progress = CGFloat(unit.lesson!.goodProgress)
                
                unit.lesson?.storeProgress = {
                    prog in
                    UIThread.performUI({self.downloadButton.stopDownloadButton?.progress = CGFloat(prog)})
                    //                    print("lesson store progress")
                }
                
                unit.lesson?.storeCompletion = {
                    downloaded, cancelled in
                    if cancelled == 0 {
                        UIThread.performUI({self.downloadButton.state = .downloaded})
                    } else {
                        UIThread.performUI({self.downloadButton.state = .startDownload})
                    }
                    CoreDataHelper.instance.save()
                }
            } else {
                downloadButton.state = .startDownload
            }
        } 
    }
    
    func initWithUnit(_ unit: Unit, delegate : PKDownloadButtonDelegate) {
        let defaultTitle = "Ooops, something got wrong"
        titleLabel.text = "\(unit.position). \(unit.lesson?.title ?? defaultTitle)"
        
        updateDownloadButton(unit)
        
        downloadButton.tag = unit.position - 1
        downloadButton.delegate = delegate
        
        progressView.backgroundColor = UIColor.white
        if let passed = unit.progress?.isPassed {
            if passed {
                progressView.backgroundColor = UIColor.stepicGreenColor()
            }
        }
        
        if let progress = unit.progress {
                if progress.cost == 0 {
                    scoreProgressView.isHidden = true
                    scoreLabel.isHidden = true
                } else {
                    scoreProgressView.progress = Float(progress.score) / Float(progress.cost)
                    scoreLabel.text = "\(progress.score)/\(progress.cost)"
                }
        }
        
                
        if !(unit.isActive || unit.section.testSectionAction != nil) {
            titleLabel.isEnabled = false
            downloadButton.isHidden = true
            scoreProgressView.isHidden = true
            scoreLabel.isHidden = true
        }
        
        if let coverURL = unit.lesson?.coverURL {
            coverImageView.sd_setImage(with: URL(string: coverURL), placeholderImage: Images.lessonPlaceholderImage.size50x50)
        } else {
            coverImageView.image = Images.lessonPlaceholderImage.size50x50
        }

    }
}
