//
//  CacheManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class CacheManager: NSObject {
    private override init() {}
    static let sharedManager = CacheManager()
    
    //Returns (successful, failed)
    func clearCache(completion completion: (Int, Int)->Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let videos = Video.getAllVideos()
            var completed = 0
            var errors = 0
            for video in videos {
                if video.state == VideoState.Cached {
                    if video.removeFromStore() {
                        completed++
                    } else {
                        errors++
                    }
                }
                if video.state == VideoState.Downloading {
                    if video.cancelStore() {
                        completed++
                    } else {
                        errors++
                    }
                }
            }
            completion(completed, errors)
        })
    }
    
    var connectionCancelled : [Video] = []
    
    func cancelAll(completion completion: (Int, Int)->Void) {
        var completed = 0
        var errors = 0
        if connectionCancelled != [] {
            completed += connectionCancelled.count 
        }
        connectionCancelled = []
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let videos = Video.getAllVideos()
            for video in videos {
                if video.state == VideoState.Downloading {
                    if video.cancelStore() {
                        completed++
                    } else {
                        errors++
                    }
                }
            }
            completion(completed, errors)
        })
    }
    
}
