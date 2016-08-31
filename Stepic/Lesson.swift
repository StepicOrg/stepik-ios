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
        coverURL = json["cover_url"].string
        stepsArray = json["steps"].arrayObject as! [Int]
    }
    
    func update(json json: JSON) {
        initialize(json)
    }
    
    func loadSteps(completion completion: (Void -> Void), error errorHandler: (String -> Void)? = nil, onlyLesson: Bool = false) {
        performRequest({
            ApiDataDownloader.sharedDownloader.getStepsByIds(self.stepsArray, deleteSteps: self.steps, refreshMode: .Update, success: {
                newSteps in 
                self.steps = Sorter.sort(newSteps, byIds: self.stepsArray)
                if !onlyLesson {
                    if let u = self.unit {
                        ApiDataDownloader.sharedDownloader.getAssignmentsByIds(u.assignmentsArray, deleteAssignments: u.assignments, refreshMode: .Update, success: {
                            newAssignments in 
                            u.assignments = Sorter.sort(newAssignments,steps: self.steps)
                            self.loadProgressesForSteps(completion)
                            }, failure: {
                                error in
                                print("Error while downloading assignments")
                                errorHandler?("Error while downloading assignments")
                        })
                    }}
                CoreDataHelper.instance.save()
                }, failure: {
                    error in
                    print("Error while downloading units")
                    errorHandler?("Error while downloading units")
            })
        })
        
    }
    
    
    
    func loadProgressesForSteps(completion: (Void->Void)) {
        var progressIds : [String] = []
        var progresses : [Progress] = []
        for step in steps {
            if let progressId = step.progressId {
                progressIds += [progressId]
            }
            if let progress = step.progress {
                progresses += [progress]
            }
        }
        
        performRequest({
            ApiDataDownloader.sharedDownloader.getProgressesByIds(progressIds, deleteProgresses: progresses, refreshMode: .Update, success: { 
                (newProgresses) -> Void in
                progresses = Sorter.sort(newProgresses, byIds: progressIds)
                for i in 0 ..< min(self.steps.count, progresses.count) {
                    self.steps[i].progress = progresses[i]
                }
                
                CoreDataHelper.instance.save()
                
                completion()
                }, failure: { 
                    (error) -> Void in
                    print("Error while dowloading progresses")
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
    
    //    var downloads = [Int : VideoDownload]()
    
    var loadingVideos : [Video]?
    
    func initLoadingVideosWithDownloading() {
        loadingVideos = []
        for step in steps {
            if step.block.name == "video" {
                if let video = step.block.video {
                    if video.state == VideoState.Downloading {
                        loadingVideos! += [video]
                    }
                }
            }
        }
    }
    
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
    
    var goodProgress : Float  {
        if loadingVideos == nil {
            initLoadingVideosWithDownloading()
        }
        
        var prog : Float = 0
        for vid in loadingVideos! {
            prog += vid.totalProgress
        }
        if loadingVideos!.count == 0 { 
            return 1 
        } else {
            return prog / Float(loadingVideos!.count)
        }
    }
    
    //    func isCompleted(videos: [Video]) -> Bool {
    //        for video in videos {
    //            if video.state == .Downloading {
    //                return false
    //            }
    //        }
    //        return true
    //    }
    
    var isDownloading : Bool {
        if steps.count == 0 {
            return false
        }
        for vid in stepVideos {
            if vid.state == VideoState.Online {
                return false
            }
        }
        return true
    }
    
    var storeProgress : ((Float) -> Void)? {
        didSet {
            if loadingVideos == nil { 
                initLoadingVideosWithDownloading()
            }
            
            for video in loadingVideos! {
                
                if video.state != VideoState.Cached { 
                    video.storedProgress = {
                        prog in
                        self.storeProgress?(self.goodProgress)
                    }
                    
                    video.storedCompletion = {
                        completed in
                        if completed {
                            self.completedVideos += 1
                        } else {
                            self.cancelledVideos += 1
                        }
                        if self.completedVideos + self.cancelledVideos == self.loadingVideos!.count {
                            print("Completed lesson store with \(self.completedVideos) completed videos & \(self.cancelledVideos) cancelled videos")
                            self.storeCompletion?(self.completedVideos, self.cancelledVideos)
                        }
                    }
                }
            }
        }
    }
    
    var storeCompletion : ((Int, Int) -> Void)?
    var completedVideos : Int = 0
    var cancelledVideos : Int = 0
    //returns completed & cancelled videos
    
    func storeVideos(progress progress : (Float) -> Void, completion : (Int, Int) -> Void, error errorHandler: NSError? -> Void) {
        
        storeProgress = progress
        storeCompletion = completion
        
        loadingVideos = []
        for step in steps {
            if step.block.name == "video" {
                if let video = step.block.video {
                    if video.state == VideoState.Downloading || video.state == VideoState.Online {
                        loadingVideos! += [video]
                    }
                }
            }
        }
        
        //        for vid in stepVideos! {
        //            if vid.isCached {
        //                summaryProgress += 1
        //            }
        //        }
        
        completedVideos = 0
        cancelledVideos = 0
        
        if loadingVideos!.count == 0 {
            progress(1)
            completion(completedVideos, cancelledVideos)
            return 
        }
        
        for vid in loadingVideos! {
            vid.store(VideosInfo.videoQuality, progress: {
                prog in
                self.storeProgress?(self.goodProgress)
                }, completion : {
                    completed in
                    if completed {
                        self.completedVideos += 1
                    } else {
                        self.cancelledVideos += 1
                    }
                    if self.completedVideos + self.cancelledVideos == self.loadingVideos!.count {
                        print("Completed lesson store with \(self.completedVideos) completed videos & \(self.cancelledVideos) cancelled videos")
                        self.storeCompletion?(self.completedVideos, self.cancelledVideos)
                    } 
                }, error: {
                    error in
                    
                    self.storeCompletion?(self.completedVideos, self.cancelledVideos)
                    
                    print("Video download error in lesson")
                    print(error?.localizedFailureReason)
                    print(error?.code)
                    print(error?.localizedDescription)
                    
                    self.completedVideos = 0
                    self.cancelledVideos = 0
                    
                    errorHandler(error)
            })                
        }
    }
    
    var isCached : Bool {
        if steps.count == 0 {
            return false
        }
        
        for vid in stepVideos {
            if vid.state != VideoState.Cached { 
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
                if vid.state != VideoState.Cached { 
                    vid.cancelStore()
                } else {
                    //                    vid.removeFromStore()
                }
            }
            
            self.completedVideos = 0
            self.cancelledVideos = 0
            completion()
        }
    }
    
    func removeFromStore(completion completion: Void -> Void) {
        print("entered lesson removeFromStore")
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            for vid in self.stepVideos {
                if vid.state != VideoState.Cached { 
                    print("not cached video can not be removed!")
                    vid.cancelStore()
                } else {
                    vid.removeFromStore()
                }
            }
            
            self.completedVideos = 0
            self.cancelledVideos = 0
            
            completion()
        }
    }
    
}
