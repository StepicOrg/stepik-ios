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
    
    func loadSteps(completion completion: (Void -> Void), refresh : Bool = true, onlyLesson: Bool = false) {
        let getStepsBlock = 
        {ApiDataDownloader.sharedDownloader.getStepsByIds(self.stepsArray, deleteSteps: self.steps, refreshMode: .Update, success: {
            newSteps in 
            self.steps = Sorter.sort(newSteps, byIds: self.stepsArray)
            if !onlyLesson {
                if let u = self.unit {
                    ApiDataDownloader.sharedDownloader.getAssignmentsByIds(u.assignmentsArray, deleteAssignments: u.assignments, refreshMode: .Update, success: {
                        newAssignments in 
                        u.assignments = Sorter.sort(newAssignments,steps: self.steps)
                        completion()
                        }, failure: {
                            error in
                            print("Error while downloading assignments")
                    })
                }}
            CoreDataHelper.instance.save()
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
                            self.completedVideos++
                        } else {
                            self.cancelledVideos++
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
                        self.completedVideos++
                    } else {
                        self.cancelledVideos++
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
