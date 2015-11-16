//
//  VideosInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct VideosInfo {
    
    private static let videoQualityKey = "VideoQuality"
    
    private static let defaults = NSUserDefaults.standardUserDefaults()

    static var videoQuality : VideoQuality {
        get {
            if let quality = defaults.valueForKey(videoQualityKey) as? String {
                print("VideosInfo did get quality \(VideoQuality(quality: quality))")
                return VideoQuality(quality: quality)
            } else {
                print("No videoQuality key in defaults")
                if DeviceInfo.isIPad() {
                    self.videoQuality = .Medium
                    return .Medium
                } else {
                    self.videoQuality = .Low
                    return .Low
                }
            }
        }
        
        set(value) {
            defaults.setObject(value.rawString, forKey: videoQualityKey)
            defaults.synchronize()
        }
    }
}