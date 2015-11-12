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
        slug = json["slug"].stringValue
        
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
    
//    var downloads = [Int : VideoDownload]()
    
    var stepVideos : [Video] {
        var res : [Video] = []
        for step in steps {
            if step.block.name == "video" {
                if let video = step.block.video {
                    res += [video]
                }
            }
        }
        return res
    }
    
    var summaryProgress : Float = 0
    
    var goodProgress : Float  {
        if stepVideos.count == 0 { 
            return 1 
        } else {
            return self.summaryProgress / Float(stepVideos.count)
        }
    }
    
    var isDownloading : Bool = false
    
    var storeProgress : ((Float) -> Void)? 
    var storeCompletion : ((Int, Int) -> Void)?
    
    //returns completed & cancelled videos
    func storeVideos(progress progress : (Float) -> Void, completion : (Int, Int) -> Void, error errorHandler: NSError? -> Void) {
        
        storeProgress = progress
        storeCompletion = completion

        isDownloading = true
        
        summaryProgress = 0
        
        for vid in stepVideos {
            if vid.isDownloading {
                summaryProgress += 1
            }
        }
        
        var completedVideos : Int = 0
        var cancelledVideos : Int = 0
        
        if stepVideos.count == 0 {
            isDownloading = false
            progress(1)
            completion(completedVideos, cancelledVideos)
            return 
        }
        
        for vid in stepVideos {
            var videoProgress : Float = 0.0
            vid.store(VideosInfo.videoQuality, progress: {
                prog in
                self.summaryProgress = self.summaryProgress - videoProgress + prog
                videoProgress = prog
                self.storeProgress?(self.goodProgress)
            }, completion : {
                completed in
                if completed {
                    completedVideos++
                } else {
                    cancelledVideos++
                }
                if completedVideos + cancelledVideos == self.stepVideos.count {
                    self.isDownloading = false
                    print("Completed lesson store with \(completedVideos) completed videos & \(cancelledVideos) cancelled videos")
                    self.storeCompletion?(completedVideos, cancelledVideos)
                }
            }, error: {
                error in
                
                self.isDownloading = false
                self.storeCompletion?(completedVideos, cancelledVideos)
                
                print("Video download error in lesson")
                self.summaryProgress = 0
                errorHandler(error)
            })                
        }
    }
    
    var isCached : Bool {
        if steps.count == 0 {
            return false
        }
        
        for vid in stepVideos{
            if !vid.isCached { 
                return false
            }
        }
        return true
    }
    
    func cancelVideoStore(completion completion : Void -> Void) {
        if self.isCached {
            completion()
            return
        }
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            for vid in self.stepVideos {
                if !vid.isCached { 
                    vid.cancelStore()
                } else {
//                    vid.removeFromStore()
                }
            }
            
            self.isDownloading = false
            self.summaryProgress = 0
            
            completion()
        }
    }
    
    func removeFromStore(completion completion: Void -> Void) {
        print("entered lesson removeFromStore")
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            for vid in self.stepVideos {
                if !vid.isCached { 
                    print("not cached video can not be removed!")
                    vid.cancelStore()
                } else {
                    vid.removeFromStore()
                }
            }
            
            self.isDownloading = false
            self.summaryProgress = 0
            
            completion()
        }
    }
    
}
