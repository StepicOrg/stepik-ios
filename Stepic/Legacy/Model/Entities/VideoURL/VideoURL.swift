//
//  VideoURL.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class VideoURL: NSManagedObject {
    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.quality = json["quality"].stringValue
        self.url = json["url"].stringValue
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? VideoURL else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.quality != object.quality { return false }
        if self.url != object.url { return false }

        return true
    }
}
