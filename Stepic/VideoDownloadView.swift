//
//  VideoDownloadView.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class VideoDownloadView: UIView {

    @IBOutlet weak var qualityLabel: UILabel!
    @IBOutlet weak var downloadButton: PKDownloadButton!
    
    var video : Video!
    
    var quality : String! {
        didSet {
            qualityLabel.text = "\(quality ?? "0")p"
        }
    }
    
    var view: UIView!
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "VideoDownloadView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        setup()
    } 
    
    
    var downloadDelegate : VideoDownloadDelegate?
    
    convenience init(frame: CGRect, video: Video, buttonDelegate: PKDownloadButtonDelegate, downloadDelegate: VideoDownloadDelegate) {
        self.init(frame: frame)
                
        self.video = video
//        self.quality = video.cachedQuality ?? VideosInfo.videoQuality

//        print("quality -> \(quality)")
        downloadButton.delegate = buttonDelegate
        self.downloadDelegate = downloadDelegate
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton, white: true)
        updateButton()
    }
    
    
    func updateButton() {
        if video.state == VideoState.cached {
            downloadButton.state = .downloaded
            self.quality = video.cachedQuality ?? VideosInfo.videoQuality 
            return
        }
        
        if video.state == VideoState.downloading {
            downloadButton.state = .downloading
            self.quality = self.video.loadingQuality ?? VideosInfo.videoQuality
            UIThread.performUI({self.downloadButton.stopDownloadButton?.progress = CGFloat(self.video.totalProgress)})
            video.storedProgress = {
                prog in
                UIThread.performUI({self.downloadButton.stopDownloadButton?.progress = CGFloat(prog)})
            }
            video.storedCompletion = {
                completed in
                if completed {
                    UIThread.performUI({self.downloadButton.state = .downloaded})
                    self.downloadDelegate?.didDownload(self.video, cancelled: false)
                } else {
                    UIThread.performUI({self.downloadButton.state = .startDownload})
                    self.downloadDelegate?.didDownload(self.video, cancelled: true)
                }
            }
            return
        }
        
        if video.state == .online {
            downloadButton.state = .startDownload
            self.quality = video.getNearestQualityToDefault(VideosInfo.videoQuality)
            return
        }
        
        downloadButton.state = .pending
        print("Something got wrong while initializing download button state. Should not be pending")
    }

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}
