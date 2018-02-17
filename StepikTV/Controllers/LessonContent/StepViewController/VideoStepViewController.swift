//
//  VideoStepViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 16.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class VideoStepViewController: TVPlayerViewController {

    var stepPosition: Int!

    override func playVideo() {
        super.playVideo()

        NotificationCenter.default.post(name: .stepUpdated, object: nil, userInfo: ["id": stepPosition])
    }

}
