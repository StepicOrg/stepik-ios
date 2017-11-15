//
//  VideoDownloadView.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class VideoDownloadView: NibInitializableView {
    @IBOutlet weak var downloadButton: PKDownloadButton!

    override var nibName: String {
        return "VideoDownloadView"
    }

    var video: Video!

    weak var downloadDelegate: VideoDownloadDelegate?

    convenience init(frame: CGRect, video: Video, buttonDelegate: PKDownloadButtonDelegate, downloadDelegate: VideoDownloadDelegate) {
        self.init(frame: frame)

        self.video = video
        downloadButton.delegate = buttonDelegate
        self.downloadDelegate = downloadDelegate
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton, white: false)
        updateButton()
    }

    func updateButton() {
        if video.state == VideoState.cached {
            downloadButton.state = .downloaded
            return
        }

        if video.state == VideoState.downloading {
            downloadButton.state = .downloading
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
            return
        }

        downloadButton.state = .pending
        print("Something got wrong while initializing download button state. Should not be pending")
    }

    deinit {
        print("deinit video download view")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}
