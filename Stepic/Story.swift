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
        self.parts = json["parts"].arrayValue.map { StoryPart(json: $0, storyID: id) }
        self.isViewed = CachedValue<Bool>(key: "isViewed_id\(id)", defaultValue: false)
        self.position = json["position"].intValue
    }

    var id: Int
    var coverPath: String
    var title: String
    var isViewed: CachedValue<Bool>
    var parts: [StoryPart]
    var position: Int

    required init(json: JSON) {
        let id = json["id"].intValue
        self.id = json["id"].intValue
        self.coverPath = HTMLProcessor.addStepikURLIfNeeded(url: json["cover"].stringValue)
        self.title = json["title"].stringValue
        self.isViewed = CachedValue<Bool>(key: "isViewed_id\(id)", defaultValue: false)
        self.parts = json["parts"].arrayValue.compactMap {
            Story.buildStoryPart(json: $0, storyID: id)
        }
        self.position = json["position"].intValue
    }

    private static func buildStoryPart(json: JSON, storyID: Int) -> StoryPart? {
        guard let type = json["type"].string else {
            return nil
        }

        switch type {
        case "text":
            return TextStoryPart(json: json, storyID: storyID)
        default:
            return nil
        }
    }
}

class StoryPart {
    var type: PartType?
    var position: Int
    var duration: Double
    var storyID: Int

    init(json: JSON, storyID: Int) {
        self.type = PartType(rawValue: json["type"].stringValue)
        self.position = json["position"].intValue - 1
        self.duration = json["duration"].doubleValue
        self.storyID = storyID
    }

//    init(type: String, position: Int, duration: Double) {
//        self.type = PartType(rawValue: type)
//        self.position = position - 1
//        self.duration = duration
//    }

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
        var backgroundStyle: BackgroundStyle

        enum BackgroundStyle: String {
            case light, dark, none

            var backgroundColor: UIColor {
                switch self {
                case .light:
                    return UIColor.white.withAlphaComponent(0.7)
                case .dark:
                    return UIColor.mainDark.withAlphaComponent(0.7)
                default:
                    return UIColor.clear
                }
            }
        }
    }

    var text: Text?

    struct Button {
        var title: String
        var urlPath: String
        var backgroundColor: UIColor
        var titleColor: UIColor
    }
    var button: Button?

    override init(json: JSON, storyID: Int) {
        imagePath = HTMLProcessor.addStepikURLIfNeeded(url: json["image"].stringValue)

        let textJSON = json["text"]
        if textJSON != JSON.null {
            let title = textJSON["title"].string
            let text = textJSON["text"].string
            let colorHexInt = Int(textJSON["text_color"].stringValue, radix: 16) ?? 0x000000
            let textColor = UIColor(hex: colorHexInt)
            let backgroundStyle = Text.BackgroundStyle(rawValue: textJSON["background_style"].stringValue) ?? .none
            self.text = Text(title: title, text: text, textColor: textColor, backgroundStyle: backgroundStyle)
        }

        let buttonJSON = json["button"]
        if buttonJSON != JSON.null {
            let title = buttonJSON["title"].stringValue
            let urlPath = buttonJSON["url"].stringValue
            let backgroundColorHexInt = Int(buttonJSON["background_color"].stringValue, radix: 16) ?? 0x000000
            let backgroundColor = UIColor(hex: backgroundColorHexInt)
            let titleColorHexInt = Int(buttonJSON["text_color"].stringValue, radix: 16) ?? 0x000000
            let titleColor = UIColor(hex: titleColorHexInt)
            self.button = Button(title: title, urlPath: urlPath, backgroundColor: backgroundColor, titleColor: titleColor)
        }

        super.init(json: json, storyID: storyID)
    }
}
