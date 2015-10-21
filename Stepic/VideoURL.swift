//
//  VideoURL.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class VideoURL: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        quality = json["quality"].stringValue
//        print(quality)
        url = json["url"].stringValue        
    }
}
