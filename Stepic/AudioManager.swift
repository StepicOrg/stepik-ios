//
//  AudioManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import AVFoundation
import UIKit

final class AudioManager: NSObject {
    override fileprivate init() { super.init() }
    static let sharedManager = AudioManager()

    var ignoreMuteSwitch: Bool {
        get {
            let currentCategory = AVAudioSession.sharedInstance().category
            print("in isIgnoring, current category = \(currentCategory))")
            return currentCategory == .playback
        }

        set(ignore) {
            do {
                print("setting ignore status to \(ignore)")
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(!ignore)
            } catch {
                print("Error while setting ignore mute switch")
            }
        }
    }

    func initAudioSession() -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default)
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
