//
//  Lesson.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Lesson: NSManagedObject, JSONInitializable {

// Insert code here to add functionality to your managed object subclass
    
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        isFeatured = json["is_featured"].boolValue
        isPublic = json["is_public"].boolValue
        
        stepsArray = json["steps"].arrayObject as! [Int]
    }
    
    func update(json json: JSON) {
        initialize(json)
    }
    
    func loadSteps(completion completion: (Void -> Void)) {
        AuthentificationManager.sharedManager.autoRefreshToken(success: {
            ApiDataDownloader.sharedDownloader.getStepsByIds(self.stepsArray, deleteSteps: self.steps, refreshMode: .Update, success: {
                newSteps in 
                self.steps = newSteps
                CoreDataHelper.instance.save()
                completion()
                }, failure: {
                    error in
                    print("Error while downloading units")
            })
        }) 
    }
    
    func getVideoURLs() -> [String] {
        var res : [String] = []
        for step in steps {
            if step.block.name == "video" {
                if let vid = step.block.video {
                    res += [vid.urls[0].url]
                }
            }
        }
        return res
    }
    
    func storeVideos(id: Int, progress : (Int, Float) -> Void, completion : Int -> Void) {
        
        var videoCount : Int = 0
        var totalProgress : Float = 0
        var completedVideos : Int = 0
        
        for step in steps {
            if step.block.name == "video" {
                if let _ = step.block.video {
                    videoCount++
                }
            }
        }
            
        for step in steps {
            if step.block.name == "video" {
                if let vid = step.block.video {
                    var videoProgress : Float = 0.0
                    vid.store(VideosInfo.videoQuality, progress: {
                    prog in
                        totalProgress = totalProgress - videoProgress + prog
                        videoProgress = prog
//                        print("lesson progress is \(Int(totalProgress*100))%")
                        progress(id, totalProgress/Float(videoCount))
                    }, completion : {
                        completedVideos++
                        if completedVideos == videoCount {
                            self.isCached = true
                            completion(id)
                        }
                    })
                }
            }
        }
    }
    
    func cancelVideoStore(completion completion : Void -> Void) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            for step in self.steps {
                if step.block.name == "video" {
                    if let vid = step.block.video {
                        if !vid.isCached { 
                            vid.cancelStore()
                        } else {
                            vid.removeFromStore()
                        }
                    }
                }
            }
            self.isCached = false
            completion()
        }
    }
    
    func removeFromStore(completion completion: Void -> Void) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            for step in self.steps {
                if step.block.name == "video" {
                    if let vid = step.block.video {
                        if !vid.isCached { 
                            print("not cached video can not be removed!")
                            vid.cancelStore()
                        } else {
                            vid.removeFromStore()
                        }
                    }
                }
            }
            self.isCached = false
            completion()
        }
    }
    
    
    
}
