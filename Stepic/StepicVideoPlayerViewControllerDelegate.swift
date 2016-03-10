//
//  StepicVideoPlayerViewControllerDelegate.swift
//  StepicVideoPlayer
//
//  Created by Alexander Karpov on 13.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import AVFoundation 

protocol StepicVideoPlayerViewControllerDelegate {
    func playerReady(player: StepicVideoPlayerViewController)
    func playerPlaybackStateDidChange(player: StepicVideoPlayerViewController)
    func playerBufferingStateDidChange(player: StepicVideoPlayerViewController)
    
    func playerPlaybackWillStartFromBeginning(player: StepicVideoPlayerViewController)
    func playerPlaybackDidEnd(player: StepicVideoPlayerViewController)
}