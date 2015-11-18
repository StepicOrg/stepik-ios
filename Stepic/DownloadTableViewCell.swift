//
//  DownloadTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class DownloadTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lessonNameLabel: UILabel!
    @IBOutlet weak var downloadButton: PKDownloadButton!
    
    var video : Video!
    var quality : VideoQuality!
//    var downloadDelegate : VideoDownloadDelegate? {
//        didSet {
//            video.downloadDelegate = downloadDelegate
//        }
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWith( video: Video, buttonDelegate: PKDownloadButtonDelegate, downloadDelegate: VideoDownloadDelegate) {        
        thumbnailImageView.sd_setImageWithURL(NSURL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)
        nameLabel.text = "\(video.id).mp4"
        //TODO: Localize
        lessonNameLabel.text = "Lesson: \"\(video.managedBlock?.managedStep?.managedLesson?.title ?? "unknown")\""
        self.video = video
        self.quality = video.cachedQuality ?? VideosInfo.videoQuality
//        qualityLabel.text = "\(quality.rawString)p"
        
//        print("quality -> \(quality)")
        downloadButton.delegate = buttonDelegate
//        self.downloadDelegate = downloadDelegate
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton, white: false)
        updateButton()
    }
    
    
    func updateButton() {
//        video.downloadDelegate = self.downloadDelegate
        if video.isCached {
            downloadButton.state = .Downloaded
            self.quality = video.cachedQuality ?? VideosInfo.videoQuality
//            qualityLabel.text = "\(quality.rawString)p"
            return
        }
        
        if video.isDownloading {
            downloadButton.state = .Downloading
            UIThread.performUI({self.downloadButton.stopDownloadButton?.progress = CGFloat(self.video.totalProgress)})
            
            video.storedProgress = {
                prog in
                UIThread.performUI({self.downloadButton.stopDownloadButton?.progress = CGFloat(self.video.totalProgress)})
            }
            video.storedCompletion = {
                completed in
                if completed {
//                    self.downloadDelegate?.didDownload(self.video)
                } else {
                }
                UIThread.performUI({
                    self.quality = self.video.cachedQuality ?? VideosInfo.videoQuality 
//                    self.qualityLabel.text = "\(self.quality.rawString)p"
                })
            }
            return
        }
        
        if !video.isCached && !video.isDownloading {
            print("this video should not be here, it can't have the .StartDownload state! ")
        }
        
        downloadButton.state = .Pending
        print("Something got wrong while initializing download button state. Should not be pending")
    }
    
}
