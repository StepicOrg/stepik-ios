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
    private override init() { super.init() }
    static let sharedManager = AudioManager() 
    
    var ignoreMuteSwitch : Bool {
        get {
            print("in isIgnoring, current category = \(AVAudioSession.sharedInstance().category)")
            return AVAudioSession.sharedInstance().category == AVAudioSessionCategoryPlayback
        }
        
        set(ignore) {
            do {
                print("setting ignore status to \(ignore)")
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(!ignore)
            }
            catch {
                print("Error while setting ignore mute switch")
            }
        }
    }
    
    func initAudioSession() -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            return true
        }
        catch {
            return false
        }
    }
    
    
    private func changeMuteIgnoreStatusTo(ignore ignore: Bool) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setActive(!ignore)
            return true
        }
        catch {
            return false
        }
    }
}
