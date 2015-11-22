//
//  Section.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc
class Section: NSManagedObject, JSONInitializable {

// Insert code here to add functionality to your managed object subclass

    
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        position = json["position"].intValue
        isActive = json["is_active"].boolValue
        progressId = json["progress"].string
//        print("initialized section \(id) with progress id -> \(progressId)")
        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date"])
        softDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
        hardDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
        
        unitsArray = json["units"].arrayObject as! [Int]
    }
    
    func update(json json: JSON) {
        initialize(json)
    }
    
    class func getSections(id: Int) throws -> [Section] {
        let request = NSFetchRequest(entityName: "Section")
        
        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)
        var predicate = NSPredicate(value: true)
        
        let p = NSPredicate(format: "managedId == %@", id as NSNumber)
        predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate, p]) 
        
        
        request.predicate = predicate
        request.sortDescriptors = [descriptor]
        
        do {
            let results = try CoreDataHelper.instance.context.executeFetchRequest(request)
            return results as! [Section]
        }
        catch {
            throw FetchError.RequestExecution
        }
    }
    
    func loadUnits(completion completion: (Void -> Void), error errorHandler: (Void -> Void)) {
        AuthentificationManager.sharedManager.autoRefreshToken(success: {
            ApiDataDownloader.sharedDownloader.getUnitsByIds(self.unitsArray, deleteUnits: self.units, refreshMode: .Update, success: {
                newUnits in 
                self.units = Sorter.sort(newUnits, byIds: self.unitsArray)
                self.loadProgressesForUnits({
                    self.loadLessonsForUnits(completion: completion)
                })
                }, failure: {
                    error in
                    print("Error while downloading units")
                    errorHandler()
            })
            }, failure:  {
                errorHandler()
            })
    }

    func loadProgressesForUnits(completion: (Void->Void)) {
        var progressIds : [String] = []
        var progresses : [Progress] = []
        for unit in units {
            if let progressId = unit.progressId {
                progressIds += [progressId]
            }
            if let progress = unit.progress {
                progresses += [progress]
            }
        }
        
        ApiDataDownloader.sharedDownloader.getProgressesByIds(progressIds, deleteProgresses: progresses, refreshMode: .Update, success: { 
            (newProgresses) -> Void in
            progresses = Sorter.sort(newProgresses, byIds: progressIds)
            for i in 0 ..< min(self.units.count, progresses.count) {
                self.units[i].progress = progresses[i]
            }
            
            CoreDataHelper.instance.save()
            
            completion()
            }, failure: { 
            (error) -> Void in
            print("Error while dowloading progresses")
        })
    }
    
    func loadLessonsForUnits(completion completion: (Void -> Void)) {
        var lessonIds : [Int] = []
        var lessons : [Lesson] = []
        for unit in units {
            lessonIds += [unit.lessonId]
            if let lesson = unit.lesson {
                lessons += [lesson]
            }
        }
        
        ApiDataDownloader.sharedDownloader.getLessonsByIds(lessonIds, deleteLessons: lessons, refreshMode: .Update, success: {
            newLessons in
            lessons = Sorter.sort(newLessons, byIds: lessonIds)
            
            for i in 0 ..< self.units.count {
                self.units[i].lesson = lessons[i]
            }
            
            CoreDataHelper.instance.save()
            
            completion()
        }, failure: {
            error in
            print("Error while downloading units")
        })
    }
    
    func countProgress(lessons : [Lesson]) -> Float {
        var totalProgress : Float = 0
        for lesson in lessons {
            totalProgress += lesson.goodProgress 
        }
        return totalProgress / Float(lessons.count)
    }
    
    func isCompleted(lessons : [Lesson]) -> Bool {
        for lesson in lessons {
            if !lesson.isCached {
                return false
            }
        }
        return true
    }
    
    func initLoadingLessonsWithDownloading() {
        loadingLessons = []
        for id in 0 ..< units.count { 
            if let lesson = units[id].lesson {
                if lesson.isDownloading {
                    loadingLessons! += [lesson]
                }
            }
        }
    }
    
    var storeProgress : (Float -> Void)? {
        didSet {
            if loadingLessons == nil { 
                initLoadingLessonsWithDownloading()
            }
            
            for lesson in loadingLessons! {

                if !lesson.isCached { 
                    lesson.storeProgress = {
                        prog in
                        self.goodProgress = self.countProgress(self.loadingLessons!)
                        self.storeProgress?(self.goodProgress)
                    }
                    
                    lesson.storeCompletion = {
                        allDownloaded, allCancelled in
                        if allCancelled != 0 {
                            self.storeCompletion?()
                        }
                        if self.isCompleted(self.loadingLessons!) {
                            self.storeCompletion?()
                        }
                    }
                }
            }
        }
    }
//    var k = "not changed"
    var storeCompletion : (Void -> Void)? 
    
    var goodProgress : Float = 0
    
    var isDownloading : Bool {
        if units.count == 0 { 
            return false 
        }
        for unit in units {
            if let lesson = unit.lesson {
                if !lesson.isDownloading && !lesson.isCached {
                    return false
                }
            }
        }
        return true
    }
    
    var loadingLessons : [Lesson]?
    
    //TODO: Add cancelled to completion
    func storeVideos(progress progress : Float -> Void, completion : () -> Void, error errorHandler: NSError? -> Void) {
        
        storeProgress = progress
        storeCompletion = completion

        goodProgress = 0
        
        loadingLessons = []
        
        for id in 0 ..< units.count { 
            if let lesson = units[id].lesson {
                if !lesson.isCached && !lesson.isDownloading {
                    loadingLessons! += [lesson]
                }
            }
        }
        
        for lesson in loadingLessons! { 
            
            let loadblock = {
                lesson.storeVideos(progress: { 
                prog in
                    self.goodProgress = self.countProgress(self.loadingLessons!)
                    self.storeProgress?(self.goodProgress)
                }, completion: {
                    downloaded, cancelled in
                    if cancelled != 0 {
                        self.storeCompletion?()
                    }
                    if self.isCompleted(self.loadingLessons!) {
                        self.storeCompletion?()
                    }
                    
                }, error:  {
                    error in
                    errorHandler(error)
                })
            }
            if lesson.steps.count != 0 {
                loadblock()
            } else {
                lesson.loadSteps(completion: {
                    loadblock()
                }, refresh: false)
            }
        }
    }
    
    func cancelVideoStore(completion completion : Void -> Void) {
        var completedUnits : Int = 0
        for unit in units {
            if let lesson = unit.lesson {
                if !lesson.isCached {
                    lesson.cancelVideoStore(completion: {
                        completedUnits++
                        if completedUnits == self.units.count {
                            self.goodProgress = 0
                            completion()
                        }
                    })
                } else {
//                    lesson.removeFromStore(completion: {
//                        completedUnits++
//                        if completedUnits == self.units.count {
//                            self.goodProgress = 0
//                            completion()
//                        }
//                    })
                }
            }
        }
    }
    
    func removeFromStore(completion completion: Void -> Void) {
        var completedUnits : Int = 0
        for unit in units {
            if let lesson = unit.lesson {
                if !lesson.isCached {
                    print("not cached lesson can not be removed!!!")
                    lesson.cancelVideoStore(completion: {
                        completedUnits++
                        if completedUnits == self.units.count {
                            self.goodProgress = 0
                            completion()
                        }
                    })
                } else {
                    lesson.removeFromStore(completion: {
                        completedUnits++
                        if completedUnits == self.units.count {
                            self.goodProgress = 0
                            completion()
                        }
                    })
                }
            }
        }
    }
    
    
    var isCached : Bool {
        get {
            if units.count == 0 {
                return false
            }
            for unit in units {
                if let lesson = unit.lesson {
                    if !lesson.isCached {
                        return false
                    }
                } else {
                    return false
                }
            }
            return true
        }
    }
    
    
//    func loadIfNotLoaded(success success : (Void -> Void)) {
//        if !loaded {
//            ApiDataDownloader.sharedDownloader.getSectionById(id, existingSection: self, refreshToken: false, success: {
//                    sec in
//                    success()
//                }, failure: {
//                    error in
//                    print("failed to load section with id -> \(self.id)")
//            })
//        } else {
//            success()
//        }
//    }
}


