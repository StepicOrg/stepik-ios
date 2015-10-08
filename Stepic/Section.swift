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
class Section: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    
    convenience init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        position = json["position"].intValue
        isActive = json["is_active"].boolValue
        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date"])
        softDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
        hardDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
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


