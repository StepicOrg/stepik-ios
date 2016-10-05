//
//  VideosInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct VideosInfo {
    
    fileprivate static let videoQualityKey = "VideoQuality"
    fileprivate static let defaults = UserDefaults.standard

    static var videoQuality : String {
        get {
            if let quality = defaults.value(forKey: videoQualityKey) as? String {
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
            defaults.set(value, forKey: videoQualityKey)
            defaults.synchronize()
        }
    }
    
    
    fileprivate static let videoRateKey = "VideoRate"
    
    static var videoRate: Float {
        get {
            if let rate = defaults.value(forKey: videoRateKey) as? Float {
                return rate
            } else {
                return 1
            }
        }
        
        set(value) {
            print("setting \(value)")
            defaults.set(value, forKey: videoRateKey)
            defaults.synchronize()
        }
    }
    
}
