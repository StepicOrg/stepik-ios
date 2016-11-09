//
//  CacheManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class CacheManager: NSObject {
    fileprivate override init() {}
    static let sharedManager = CacheManager()
    
    //Returns (successful, failed)
    func clearCache(completion: @escaping (Int, Int)->Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            let videos = Video.getAllVideos()
            var completed = 0
            var errors = 0
            for video in videos {
                if video.state == VideoState.cached {
                    if video.removeFromStore() {
                        completed += 1
                    } else {
                        errors += 1
                    }
                }
                if video.state == VideoState.downloading {
                    if video.cancelStore() {
                        completed += 1
                    } else {
                        errors += 1
                    }
                }
            }
            completion(completed, errors)
        })
    }
    
    var connectionCancelled : [Video] = []
    
    func cancelAll(completion: @escaping (Int, Int)->Void) {
        var completed = 0
        var errors = 0
        if connectionCancelled != [] {
            completed += connectionCancelled.count 
        }
        connectionCancelled = []
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            let videos = Video.getAllVideos()
            for video in videos {
                if video.state == VideoState.downloading {
                    if video.cancelStore() {
                        completed += 1
                    } else {
                        errors += 1
                    }
                }
            }
            completion(completed, errors)
        })
    }
    
}
