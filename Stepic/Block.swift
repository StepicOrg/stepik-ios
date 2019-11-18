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
        self.initialize(json)
        self.video = Video(json: json[JSONKey.video.rawValue])
    }

    func initialize(_ json: JSON) {
        self.name = json[JSONKey.name.rawValue].stringValue
        self.text = json[JSONKey.text.rawValue].string
    }

    func update(json: JSON) {
        self.initialize(json)
        if let video = self.video {
            video.update(json: json[JSONKey.video.rawValue])
        }
    }

    enum JSONKey: String {
        case name
        case text
        case video
    }
}
