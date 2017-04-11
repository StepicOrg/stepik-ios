//
//  Certificate+CoreDataClass.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Certificate: NSManagedObject, JSONInitializable {
    typealias idType = Int
    
    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }
    
    func initialize(_ json: JSON) {
        self.id = json["id"].intValue
        self.userId = json["user"].intValue
        self.courseId = json["course"].intValue
        self.issueDate = Parser.sharedParser.dateFromTimedateJSON(json["issue_date"])
        self.updateDate = Parser.sharedParser.dateFromTimedateJSON(json["update_date"])
        self.grade = json["grade"].intValue
        self.type = CertificateType(rawValue: json["type"].stringValue) ?? .regular
        self.urlString = json["url"].string
        self.isPublic = json["is_public"].bool
    }
    
    func update(json: JSON) {
        initialize(json)
    }
    
    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].int
    }
    
}
