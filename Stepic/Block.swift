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
        guard let text = self.text else {
            return []
        }

        let sources = HTMLExtractor.extractAllTagsAttribute(tag: "img", attribute: "src", from: text)
        let urls = Set(sources.compactMap { URL(string: $0) })

        return Array(urls)
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

    // MARK: - Types -

    enum BlockType: String {
        case animation
        case chemical
        case choice
        case code
        case dataset
        case matching
        case math
        case number
        case puzzle
        case pycharm
        case sorting
        case sql
        case string
        case text
        case video
        case admin
        case table
        case html
        case schulte
        case fillBlanks = "fill-blanks"
        case freeAnswer = "free-answer"
        case linuxCode = "linux-code"
        case randomTasks = "random-tasks"
        case manualScore = "manual-score"

        var isTheory: Bool { [BlockType.text, BlockType.video].contains(self) }
    }

    enum JSONKey: String {
        case name
        case text
        case video
    }
}
