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
import MagicalRecord

class Lesson: NSManagedObject, JSONInitializable {
    
    // Insert code here to add functionality to your managed object subclass
    typealias idType = Int

    
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(_ json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        isFeatured = json["is_featured"].boolValue
        isPublic = json["is_public"].boolValue
        slug = json["slug"].stringValue
        coverURL = json["cover_url"].string
        stepsArray = json["steps"].arrayObject as! [Int]
    }
    
    static func getLesson(_ id: Int) -> Lesson? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")
        
        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)        
        
        request.predicate = predicate
        
        do {
            let results = try CoreDataHelper.instance.context.fetch(request) 
            return (results as? [Lesson])?.first
        }
        catch {
            return nil
        }

//        return Lesson.MR_findFirstWithPredicate(NSPredicate(format: "managedId == %@", id as NSNumber))
    }
    
    func update(json: JSON) {
        initialize(json)
    }
    
    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].intValue
    }
    
    func loadSteps(completion: @escaping ((Void) -> Void), error errorHandler: ((String) -> Void)? = nil, onlyLesson: Bool = false) {
        _ = ApiDataDownloader.steps.retrieve(ids: self.stepsArray, existing: self.steps, refreshMode: .update, success: {
            newSteps in 
            self.steps = Sorter.sort(newSteps, byIds: self.stepsArray)
            self.loadProgressesForSteps({
                if !onlyLesson {
                    if let u = self.unit {
                        _ = ApiDataDownloader.assignments.retrieve(ids: u.assignmentsArray, existing: u.assignments, refreshMode: .update, success: {
                            newAssignments in 
                            u.assignments = Sorter.sort(newAssignments,steps: self.steps)
                            completion()
                            }, error: {
                                error in
                                print("Error while downloading assignments")
                                errorHandler?("Error while downloading assignments")
                        })
                    } else {
                        completion()
                    }
                } else {
                    completion()
                }
            })
            CoreDataHelper.instance.save()
            }, error: {
                error in
                print("Error while downloading steps")
                errorHandler?("Error while downloading steps")
        })
        
    }
    
    
    
    func loadProgressesForSteps(_ completion: @escaping ((Void)->Void)) {
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
        
        _ = ApiDataDownloader.progresses.retrieve(ids: progressIds, existing: progresses, refreshMode: .update, success: { 
            (newProgresses) -> Void in
            progresses = Sorter.sort(newProgresses, byIds: progressIds)
            for i in 0 ..< min(self.steps.count, progresses.count) {
                self.steps[i].progress = progresses[i]
            }
            
            CoreDataHelper.instance.save()
            
            completion()
            }, error: { 
                (error) -> Void in
                print("Error while dowloading progresses")
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
                    if video.state == VideoState.downloading {
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
            if vid.state == VideoState.online {
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
                
                if video.state != VideoState.cached { 
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
    
    func storeVideos(progress : @escaping (Float) -> Void, completion : @escaping (Int, Int) -> Void, error errorHandler: @escaping (NSError?) -> Void) {
        
        storeProgress = progress
        storeCompletion = completion
        
        loadingVideos = []
        for step in steps {
            if step.block.name == "video" {
                if let video = step.block.video {
                    if video.state == VideoState.downloading || video.state == VideoState.online {
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
            vid.store(VideosInfo.downloadingVideoQuality, progress: {
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
                    print(error?.localizedFailureReason ?? "")
                    print(error?.code ?? "")
                    print(error?.localizedDescription ?? "")
                    
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
            if vid.state != VideoState.cached { 
                return false
            }
        }
        return true
    }
    
    func cancelVideoStore(completion : @escaping (Void) -> Void) {
        if self.isCached {
            completion()
            return
        }
        
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            for vid in self.stepVideos {
                if vid.state != VideoState.cached { 
                    _ = vid.cancelStore()
                } else {
                    //                    vid.removeFromStore()
                }
            }
            
            self.completedVideos = 0
            self.cancelledVideos = 0
            completion()
        }
    }
    
    func removeFromStore(completion: @escaping (Void) -> Void) {
        print("entered lesson removeFromStore")
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            for vid in self.stepVideos {
                if vid.state != VideoState.cached { 
                    print("not cached video can not be removed!")
                    _ = vid.cancelStore()
                } else {
                    _ = vid.removeFromStore()
                }
            }
            
            self.completedVideos = 0
            self.cancelledVideos = 0
            
            completion()
        }
    }
    
}
