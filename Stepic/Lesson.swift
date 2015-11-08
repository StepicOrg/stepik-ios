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
    
    func loadSteps(completion completion: (Void -> Void), refresh : Bool = true) {
        let getStepsBlock = {ApiDataDownloader.sharedDownloader.getStepsByIds(self.stepsArray, deleteSteps: self.steps, refreshMode: .Update, success: {
            newSteps in 
            self.steps = Sorter.sort(newSteps, byIds: self.stepsArray)
            CoreDataHelper.instance.save()
            completion()
            }, failure: {
                error in
                print("Error while downloading units")
        })}
        if refresh {
            AuthentificationManager.sharedManager.autoRefreshToken(success: {
                getStepsBlock()
            })
        } else {
            getStepsBlock()
        }
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
    
    var downloads = [Int : VideoDownload]()
    
    var totalProgress : Float = 0
    var isDownloading : Bool = false
    
    var storeProgress : ((Int, Float) -> Void)? {
        didSet {
            print("lesson store progress handler did change")
        }
    }
    var storeCompletion : (Int -> Void)?
    
    func storeVideos(id: Int, progress : (Int, Float) -> Void, completion : Int -> Void) {
        
        storeProgress = progress
        storeCompletion = completion

        isDownloading = true
        var videoCount : Int = 0
        totalProgress = 0
        var completedVideos : Int = 0
        
        for step in steps {
            if step.block.name == "video" {
                if let _ = step.block.video {
                    videoCount++
                }
            }
        }
            
        if videoCount == 0 {
            isDownloading = false
            isCached = true
            progress(id, 1)
            completion(id)
            return
        }
        
        for step in steps {
            if step.block.name == "video" {
                if let vid = step.block.video {
                    var videoProgress : Float = 0.0
                    vid.store(VideosInfo.videoQuality, progress: {
                    prog in
                        self.totalProgress = self.totalProgress - videoProgress + prog
                        videoProgress = prog
//                        print("lesson progress is \(Int(totalProgress*100))%")
                        self.storeProgress?(id, self.totalProgress/Float(videoCount))
                    }, completion : {
                        completedVideos++
                        if completedVideos == videoCount {
                            self.isCached = true
                            self.isDownloading = false
                            self.storeCompletion?(id)
                        }
                    })
                    if let d = vid.download {
                        downloads[vid.id] = d
                    }
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
                        self.downloads[vid.id] = nil
                    }
                }
            }
            self.isDownloading = false
            self.isCached = false
            self.totalProgress = 0
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
                        self.downloads[vid.id] = nil
                    }
                }
            }
            self.isDownloading = false
            self.isCached = false
            self.totalProgress = 0
            completion()
        }
    }
    
    
    
}
