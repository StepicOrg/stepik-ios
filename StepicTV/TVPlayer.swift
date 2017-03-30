//
//  TVPlayer.swift
//  Stepic
//
//  Created by Anton Kondrashov on 30/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import AVKit

class TVPlayerViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func playVideo(url: URL) {
        player = AVPlayer.init(url: url)
        player?.play()
    }
    
}
