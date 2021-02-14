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
    var type: BlockType? { BlockType(rawValue: self.name) }

    var image: UIImage {
        switch self.type {
        case .text:
            return UIImage(named: "ic_theory_dark").require()
        case .video:
            return UIImage(named: "ic_video_dark").require()
        case .code, .dataset, .admin, .sql:
            return UIImage(named: "ic_hard_dark").require()
        default:
            return UIImage(named: "ic_easy_dark").require()
        }
    }

    /// The extracted `src` attributes from `text` property.
    var imageSourceURLs: [URL] {
        ImageSourceURLExtractor(text: self.text ?? "").extractAllImageSourceURLs()
    }

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

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? Block else {
            return false
        }

        if self === object { return true }

        if self.name != object.name { return false }
        if self.text != object.text { return false }

        if let video = self.video {
            if !video.equals(object.video) { return false }
        } else if object.video != nil { return false }

        return true
    }

    enum JSONKey: String {
        case name
        case text
        case video
    }
}
