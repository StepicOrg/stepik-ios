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

    static var videoQuality : String {
        get {
            if let quality = defaults.valueForKey(videoQualityKey) as? String {
                return quality
            } else {
                if DeviceInfo.isIPad() {
                    return "720"
                } else {
                    return "360"
                }
            }
        }
        
        set(value) {
            print("setting \(value)")
            defaults.setObject(value, forKey: videoQualityKey)
            defaults.synchronize()
        }
    }
}