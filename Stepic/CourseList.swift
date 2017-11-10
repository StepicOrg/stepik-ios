//
//  CourseList.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class CourseList: NSManagedObject, JSONInitializable {
    typealias idType = Int
    
    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }
    
    func initialize(_ json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        listDescription = json["description"].stringValue
        position = json["position"].intValue
        languageString = json["language"].stringValue
        coursesArray = json["courses"].arrayObject as! [Int]
    }
    
    func update(json: JSON) {
        initialize(json)
    }
    
    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].int
    }

}
