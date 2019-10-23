//
//  Block.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class Block: NSManagedObject {
    required convenience init(json: JSON) {
        self.init()
        initialize(json)
        video = Video(json: json["video"])
    }

    func initialize(_ json: JSON) {
        name = json["name"].stringValue
        text = json["text"].string
    }

    func update(json: JSON) {
        initialize(json)
        if let v = video {
            v.update(json: json["video"])
        }
    }
}
