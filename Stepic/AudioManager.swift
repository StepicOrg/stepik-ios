//
//  AudioManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import AVFoundation

class AudioManager: NSObject {
    fileprivate override init() { super.init() }
    static let sharedManager = AudioManager()

    var ignoreMuteSwitch: Bool {
        get {
            print("in isIgnoring, current category = \(convertFromAVAudioSessionCategory(AVAudioSession.sharedInstance().category))")
            return convertFromAVAudioSessionCategory(AVAudioSession.sharedInstance().category) == convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)
        }

        set(ignore) {
            do {
                print("setting ignore status to \(ignore)")
                if #available(iOS 10.0, *) {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default)
                } else {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [])
                }
                try AVAudioSession.sharedInstance().setActive(!ignore)
            } catch {
                print("Error while setting ignore mute switch")
            }
        }
    }

    func initAudioSession() -> Bool {
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default)
            } else {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [])
            }
            return true
        } catch {
            return false
        }
    }

    fileprivate func changeMuteIgnoreStatusTo(ignore: Bool) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setActive(!ignore)
            return true
        } catch {
            return false
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
