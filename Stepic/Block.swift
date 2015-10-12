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

class Block: NSManagedObject, JSONInitializable {

// Insert code here to add functionality to your managed object subclass
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        name = json["name"].stringValue
        text = json["text"].string
        video = json["video"].string
        animation = json["animation"].string
    }
    
}
