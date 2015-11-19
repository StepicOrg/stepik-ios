//
//  Course.swift
//  
//
//  Created by Alexander Karpov on 25.09.15.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc
class Course: NSManagedObject, JSONInitializable {

// Insert code here to add functionality to your managed object subclass
    
    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        courseDescription = json["description"].stringValue
        coverURLString = Constants.stepicURLString + json["cover"].stringValue
        
        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date_source"])
        endDate = Parser.sharedParser.dateFromTimedateJSON(json["last_deadline"])
        
        enrolled = json["enrollment"].int != nil
        featured = json["is_featured"].boolValue
        
        summary = json["summary"].stringValue
        workload = json["workload"].stringValue
        introURL = json["intro"].stringValue
        format = json["course_format"].stringValue
        audience = json["target_audience"].stringValue
        certificate = json["certificate"].stringValue
        requirements = json["requirements"].stringValue
        
        sectionsArray = json["sections"].arrayObject as! [Int]
        instructorsArray = json["instructors"].arrayObject as! [Int]
    }
    
    
    func update(json json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        courseDescription = json["description"].stringValue
        coverURLString = Constants.stepicURLString + json["cover"].stringValue
        
        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date_source"])
        endDate = Parser.sharedParser.dateFromTimedateJSON(json["last_deadline"])
        
        enrolled = json["enrollment"].int != nil
        featured = json["is_featured"].boolValue
        
        summary = json["summary"].stringValue
        workload = json["workload"].stringValue
        introURL = json["intro"].stringValue
        format = json["course_format"].stringValue
        audience = json["target_audience"].stringValue
        certificate = json["certificate"].stringValue
        requirements = json["requirements"].stringValue
        
        sectionsArray = json["sections"].arrayObject as! [Int]
        instructorsArray = json["instructors"].arrayObject as! [Int]
    }
    
        
    func loadAllInstructors(success success: (Void -> Void)) {
        AuthentificationManager.sharedManager.autoRefreshToken(success: {
            ApiDataDownloader.sharedDownloader.getUsersByIds(self.instructorsArray, deleteUsers: self.instructors, refreshMode: .Update, success: {
                users in
//                print("instructors count inside Course class -> \(users.count)")
                self.instructors = Sorter.sort(users, byIds: self.instructorsArray)
                CoreDataHelper.instance.save()
                success()  
                }, failure : {
                    error in
                    print("error while loading section")
            })
        })        
    }
    
    func loadAllSections(success success: (Void -> Void), error errorHandler : (Void -> Void)) {
        AuthentificationManager.sharedManager.autoRefreshToken(success: {
            ApiDataDownloader.sharedDownloader.getSectionsByIds(self.sectionsArray, existingSections: self.sections, refreshMode: .Update, success: {
                    secs in
                    self.sections = Sorter.sort(secs, byIds: self.sectionsArray)
                    CoreDataHelper.instance.save()
                    self.loadProgressesForSections(success)
                    //success()  
                }, failure : {
                        error in
                        print("error while loading section")
                        errorHandler()
                })
            }, failure:  {
                errorHandler()
        })        
    }
    
    func loadProgressesForSections(completion: (Void->Void)) {
        var progressIds : [String] = []
        var progresses : [Progress] = []
        for section in sections {
            if let progressId = section.progressId {
                progressIds += [progressId]
            }

            if let progress = section.progress {
                progresses += [progress]
            }
        }
        
//        print("progress ids array -> \(progressIds)")
        
        ApiDataDownloader.sharedDownloader.getProgressesByIds(progressIds, deleteProgresses: progresses, refreshMode: .Update, success: { 
            (newProgresses) -> Void in
            progresses = Sorter.sort(newProgresses, byIds: progressIds)
            for i in 0 ..< min(self.sections.count, progresses.count) {
                self.sections[i].progress = progresses[i]
            }
            
            CoreDataHelper.instance.save()
            
            completion()
            }, failure: { 
                (error) -> Void in
                print("Error while dowloading progresses")
        })
    }
    
    class func getCourses(ids: [Int], featured: Bool? = nil, enrolled: Bool? = nil) throws -> [Course] {
        let request = NSFetchRequest(entityName: "Course")
        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)
        var predicate = NSPredicate(value: true)
        for id in ids {
            let p = NSPredicate(format: "managedId == %@", id as NSNumber)
            predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicate, p])
        }
        if let f = featured {
            let p = NSPredicate(format: "managedFeatured == %@", f as NSNumber)
            predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate, p])
        }
        
        if let e = enrolled {
            let p = NSPredicate(format: "managedEnrolled == %@", e as NSNumber)
            predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate, p])
        }
        
        request.predicate = predicate
        request.sortDescriptors = [descriptor]
        
        do {
            let results = try CoreDataHelper.instance.context.executeFetchRequest(request)
            return results as! [Course]
        }
        catch {
            throw FetchError.RequestExecution
        }
    }
    
    class func getAllCourses(enrolled enrolled : Bool? = nil) -> [Course] {
        let request = NSFetchRequest(entityName: "Course")
        var predicate = NSPredicate(value: true)

        if let e = enrolled {
            let p = NSPredicate(format: "managedEnrolled == %@", e as NSNumber)
            predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate, p])
        }
        
        request.predicate = predicate
        do {
            let results = try CoreDataHelper.instance.context.executeFetchRequest(request)
            return results as! [Course]
        }
        catch {
            print("Error while getting courses")
            return []
//            throw FetchError.RequestExecution
        }
    }
}

extension NSTimeInterval {
    init(timeString: String) {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        self = formatter.dateFromString(timeString)!.timeIntervalSince1970
    }
}