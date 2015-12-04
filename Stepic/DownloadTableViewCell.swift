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
    @IBOutlet weak var lessonNameLabel: UILabel!
    @IBOutlet weak var downloadButton: PKDownloadButton!
    @IBOutlet weak var qualityLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    var video : Video!
    var quality : VideoQuality! {
        didSet {
            qualityLabel.text = "\(quality.rawString)p"
        }
    }
    
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
//        lessonNameLabel.text = "\(NSLocalizedString("Lesson", comment: "")): \"\(video.managedBlock?.managedStep?.managedLesson?.title ?? "")\""
        
        lessonNameLabel.text = "\(video.managedBlock?.managedStep?.managedLesson?.title ?? "")"

        self.video = video
//        self.quality = video.cachedQuality ?? (video.loadingQuality ?? VideosInfo.videoQuality)
//        qualityLabel.text = "\(quality.rawString)p"
        
//        print("quality -> \(quality)")
        downloadButton.delegate = buttonDelegate
//        self.downloadDelegate = downloadDelegate
        
        video.getSize({
            size in
            self.sizeLabel.text = "\(size/1024/1024) \(NSLocalizedString("Mb", comment: ""))"
        })
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton, white: false)
        updateButton()
    }
    
    
    func updateButton() {
//        video.downloadDelegate = self.downloadDelegate
        if video.state ==  VideoState.Cached {
            downloadButton.state = .Downloaded
            self.quality = self.video.cachedQuality ?? VideosInfo.videoQuality 
            return
        }
        
        if video.state == VideoState.Downloading {
            downloadButton.state = .Downloading
            
            self.quality = self.video.loadingQuality! ?? VideosInfo.videoQuality

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
        
        if video.state == .Online {
            print("this video should not be here, it can't have the .Online state! ")
        }
        
        downloadButton.state = .Pending
        print("Something got wrong while initializing download button state. Should not be pending")
    }
    
}
