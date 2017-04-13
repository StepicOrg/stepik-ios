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
    typealias idType = Int
    
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(_ json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        position = json["position"].intValue
        isActive = json["is_active"].boolValue
        progressId = json["progress"].string
        //        print("initialized section \(id) with progress id -> \(progressId)")
        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date"])
        softDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
        hardDeadline = Parser.sharedParser.dateFromTimedateJSON(json["hard_deadline"])
        
        testSectionAction = json["actions"]["test_section"].string
        isExam = json["is_exam"].boolValue
        unitsArray = json["units"].arrayObject as! [Int]
    }
    
    func update(json: JSON) {
        initialize(json)
    }
    
    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].intValue
    }
    
    class func getSections(_ id: Int) throws -> [Section] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Section")
        
        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)
        var predicate = NSPredicate(value: true)
        
        let p = NSPredicate(format: "managedId == %@", id as NSNumber)
        predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, p]) 
        
        
        request.predicate = predicate
        request.sortDescriptors = [descriptor]
        
        do {
            let results = try CoreDataHelper.instance.context.fetch(request)
            return results as! [Section]
        }
        catch {
            throw FetchError.requestExecution
        }
    }
    
    func loadUnits(success: @escaping ((Void) -> Void), error errorHandler : @escaping ((Void) -> Void)) {
        
        if self.unitsArray.count == 0 {
            success()
            return
        }
        
        let requestUnitsCount = 50
        var dimCount = 0
        var idsArray = Array<Array<Int>>()
        for (index, unitId) in self.unitsArray.enumerated() {
            if index % requestUnitsCount == 0 {
                idsArray.append(Array<Int>())
                dimCount += 1
            }
            idsArray[dimCount - 1].append(unitId)
        }
        
        //            let sectionsToDownload = idsArray.count
        var downloadedUnits = [Unit]()
        
        let idsDownloaded : ([Unit]) -> (Void) = {
            uns in
            downloadedUnits.append(contentsOf: uns)
            if downloadedUnits.count == self.unitsArray.count {
                self.units = Sorter.sort(downloadedUnits, byIds: self.unitsArray)
                CoreDataHelper.instance.save()
                success()
            }
        }
        
        var wasError = false
        let errorWhileDownloading : (Void) -> (Void) = {
            if !wasError {
                wasError = true
                errorHandler()
            }
        }
        
        for ids in idsArray {
            _ = ApiDataDownloader.units.retrieve(ids: ids, existing: self.units, refreshMode: .update, success: {
                newUnits in 
                self.loadProgressesForUnits(units: newUnits, completion: {
                    self.loadLessonsForUnits(units: newUnits, completion: {
                        idsDownloaded(newUnits)
                    })
                })
                }, error: {
                    error in
                    print("Error while downloading units")
                    errorWhileDownloading()
            })
        }
    }
    
    func loadProgressesForUnits(units: [Unit], completion: @escaping ((Void)->Void)) {
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
        
        _ = ApiDataDownloader.progresses.retrieve(ids: progressIds, existing: progresses, refreshMode: .update, success: { 
            (newProgresses) -> Void in
            progresses = Sorter.sort(newProgresses, byIds: progressIds)
            for i in 0 ..< min(units.count, progresses.count) {
                units[i].progress = progresses[i]
            }
            
            CoreDataHelper.instance.save()
            
            completion()
            }, error: { 
                (error) -> Void in
                print("Error while dowloading progresses")
        })
    }
    
    func loadLessonsForUnits(units: [Unit], completion: @escaping ((Void) -> Void)) {
        var lessonIds : [Int] = []
        var lessons : [Lesson] = []
        for unit in units {
            lessonIds += [unit.lessonId]
            if let lesson = unit.lesson {
                lessons += [lesson]
            }
        }
        
        _ = ApiDataDownloader.lessons.retrieve(ids: lessonIds, existing: lessons, refreshMode: .update, success: {
            newLessons in
            lessons = Sorter.sort(newLessons, byIds: lessonIds)
            
            for i in 0 ..< units.count {
                units[i].lesson = lessons[i]
            }
            
            CoreDataHelper.instance.save()
            
            completion()
            }, error: {
                error in
                print("Error while downloading units")
        })
    }
    
    func countProgress(_ lessons : [Lesson]) -> Float {
        var totalProgress : Float = 0
        for lesson in lessons {
            totalProgress += lesson.goodProgress 
        }
        return totalProgress / Float(lessons.count)
    }
    
    func isCompleted(_ lessons : [Lesson]) -> Bool {
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
    
    var storeProgress : ((Float) -> Void)? {
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
    var storeCompletion : ((Void) -> Void)? 
    
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
    func storeVideos(progress : @escaping (Float) -> Void, completion : @escaping () -> Void, error errorHandler: @escaping (NSError?) -> Void) {
        
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
                })
            }
        }
    }
    
    func cancelVideoStore(completion : @escaping (Void) -> Void) {
        var completedUnits : Int = 0
        for unit in units {
            if let lesson = unit.lesson {
                if !lesson.isCached {
                    lesson.cancelVideoStore(completion: {
                        completedUnits += 1
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
    
    func removeFromStore(completion: @escaping (Void) -> Void) {
        var completedUnits : Int = 0
        for unit in units {
            if let lesson = unit.lesson {
                if !lesson.isCached {
                    print("not cached lesson can not be removed!!!")
                    lesson.cancelVideoStore(completion: {
                        completedUnits += 1
                        if completedUnits == self.units.count {
                            self.goodProgress = 0
                            completion()
                        }
                    })
                } else {
                    lesson.removeFromStore(completion: {
                        completedUnits += 1
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


