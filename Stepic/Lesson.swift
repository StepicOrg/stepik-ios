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
        
        stepsArray = json["steps"].arrayObject as! [Int]

    }
    
    func loadSteps(completion completion: (Void -> Void)) {
        AuthentificationManager.sharedManager.autoRefreshToken(success: {
            ApiDataDownloader.sharedDownloader.getStepsByIds(self.stepsArray, deleteSteps: self.steps, success: {
                newSteps in 
                self.steps = newSteps
                completion()
                }, failure: {
                    error in
                    print("Error while downloading units")
            })
        }) 
    }
}
