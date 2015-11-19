//
//  Unit.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Unit: NSManagedObject, JSONInitializable {

// Insert code here to add functionality to your managed object subclass
    
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        id = json["id"].intValue
        position = json["position"].intValue
        isActive = json["is_active"].boolValue
        lessonId = json["lesson"].intValue
        progressId = json["progress"].stringValue

        assignmentsArray = json["assignments"].arrayObject as! [Int]
        
        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date"])
        softDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
        hardDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
    }
    
    func update(json json: JSON) {
        initialize(json)
    }
    
    func loadAssignments(completion: (Void->Void), errorHandler: (Void->Void)) {
        AuthentificationManager.sharedManager.autoRefreshToken(success: {
            ApiDataDownloader.sharedDownloader.getAssignmentsByIds(self.assignmentsArray, deleteAssignments: self.assignments, refreshMode: .Update, success: {
                newAssignments in 
                self.assignments = Sorter.sort(newAssignments, byIds: self.assignmentsArray)
                completion()
                }, failure: {
                    error in
                    print("Error while downloading assignments")
                    errorHandler()
            })
            }, failure:  {
                errorHandler()
        })
    }
    
}
