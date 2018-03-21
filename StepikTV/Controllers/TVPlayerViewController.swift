//
//  TVPlayerViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class TVPlayerViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {

    var video: Video!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        playVideo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }

    func playVideo() {
        let url = video.getUrlForQuality("720")
        playVideo(url: url)
    }

    private func playVideo(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
    }

}
