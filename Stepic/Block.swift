//
//  Block.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Block: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience required init(json: JSON){
        self.init()
        initialize(json)
        video = Video(json: json["video"])
    }
    
    func initialize(json: JSON) {
        name = json["name"].stringValue
        text = json["text"].string
        animation = json["animation"].string
    }
    
    func update(json json: JSON) {
        initialize(json)
        if let v = video {
            v.update(json: json["video"])
        }
    }
}
