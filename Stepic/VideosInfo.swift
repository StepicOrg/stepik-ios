//
//  VideosInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct VideosInfo {

    fileprivate static let downloadingVideoQualityKey = "VideoQuality"
    fileprivate static let watchingVideoQualityKey = "WatchingVideoQuality"

    fileprivate static let defaults = UserDefaults.standard

    static var downloadingVideoQuality: String {
        get {
            if let quality = defaults.value(forKey: downloadingVideoQualityKey) as? String {
                return quality
            } else {
                #if !os(tvOS)
                    if DeviceInfo.current.isPad {
                        return "720"
                    } else {
                        return "360"
                    }
                #else
                    return "720"
                #endif
            }
        }

        set(value) {
            defaults.set(value, forKey: downloadingVideoQualityKey)
            defaults.synchronize()
        }
    }

    static var watchingVideoQuality: String {
        get {
            if let quality = defaults.value(forKey: watchingVideoQualityKey) as? String {
                return quality
            } else {
                #if !os(tvOS)
                    if DeviceInfo.current.isPad {
                        return "720"
                    } else {
                        return "360"
                    }
                #else
                    return "720"
                #endif
            }
        }

        set(value) {
            defaults.set(value, forKey: watchingVideoQualityKey)
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
