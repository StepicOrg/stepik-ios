//
//  Story.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 03.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import SwiftyJSON

class Story: JSONSerializable {
    func update(json: JSON) {
        self.id = json["id"].intValue
        self.coverPath = json["cover"].stringValue
        self.title = json["title"].stringValue
        self.parts = json["parts"].arrayValue.map { StoryPart(json: $0) }
        self.isViewed = CachedValue<Bool>(key: "isViewed_id\(id)")
    }

    var id: Int
    var coverPath: String
    var title: String
    var isViewed: CachedValue<Bool>
    var parts: [StoryPart]

    init(id: Int, coverPath: String, title: String, isViewed: Bool, parts: [StoryPart]) {
        self.id = id
        self.coverPath = coverPath
        self.title = title
        self.isViewed = CachedValue<Bool>(key: "isViewed_id\(id)", value: isViewed)
        self.parts = parts
    }

    required init(json: JSON) {
        self.id = json["id"].intValue
        self.coverPath = json["cover"].stringValue
        self.title = json["title"].stringValue
        self.isViewed = CachedValue<Bool>(key: "isViewed_id\(id)")
        self.parts = json["parts"].arrayValue.compactMap {
            Story.buildStoryPart(json: $0)
        }
    }

    private static func buildStoryPart(json: JSON) -> StoryPart? {
        guard let type = json["type"].string else {
            return nil
        }

        switch type {
        case "text":
            return TextStoryPart(json: json)
        default:
            return nil
        }
    }
}

class StoryPart {
    var type: PartType?
    var position: Int
    var duration: Double

    init(json: JSON) {
        self.type = PartType(rawValue: json["type"].stringValue)
        self.position = json["position"].intValue - 1
        self.duration = json["duration"].doubleValue
    }

    init(type: String, position: Int, duration: Double) {
        self.type = PartType(rawValue: type)
        self.position = position - 1
        self.duration = duration
    }

    enum PartType: String {
        case text
    }
}

class TextStoryPart: StoryPart {
    var imagePath: String

    struct Text {
        var title: String?
        var text: String?
        var textColor: UIColor
    }
    var text: Text?

    struct Button {
        var title: String
        var urlPath: String
    }
    var button: Button?

    override init(json: JSON) {
        imagePath = json["image"].stringValue
        let textJSON = json["text"]["\(ContentLanguage.sharedContentLanguage.languageString)"]
        if textJSON != JSON.null {
            let title = textJSON["title"].string
            let text = textJSON["text"].string
            let colorHexInt = Int(textJSON["text_color"].stringValue, radix: 16) ?? 0x000000
            let textColor = UIColor(hex: colorHexInt)
            self.text = Text(title: title, text: text, textColor: textColor)
        }

        let buttonJSON = json["button"]["\(ContentLanguage.sharedContentLanguage.languageString)"]
        if buttonJSON != JSON.null {
            let title = json["title"].stringValue
            let urlPath = json["url"].stringValue
            self.button = Button(title: title, urlPath: urlPath)
        }
        super.init(json: json)
    }
}
