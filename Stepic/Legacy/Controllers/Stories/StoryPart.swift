import Foundation
import SwiftyJSON

class StoryPart {
    var type: PartType?
    var position: Int
    var duration: Double
    var storyID: Int

    init(json: JSON, storyID: Int) {
        self.type = PartType(rawValue: json[JSONKey.type.rawValue].stringValue)
        self.position = json[JSONKey.position.rawValue].intValue - 1
        self.duration = json[JSONKey.duration.rawValue].doubleValue
        self.storyID = storyID
    }

    enum PartType: String {
        case text
    }

    enum JSONKey: String {
        case type
        case position
        case duration
    }
}

// MARK: - TextStoryPart -

final class TextStoryPart: StoryPart {
    var imagePath: String
    var text: Text?
    var button: Button?

    override init(json: JSON, storyID: Int) {
        self.imagePath = HTMLProcessor.addStepikURLIfNeeded(url: json[JSONKey.image.rawValue].stringValue)

        let textJSON = json[JSONKey.text.rawValue]
        if textJSON != JSON.null {
            let title = textJSON[JSONKey.title.rawValue].string
            let text = textJSON[JSONKey.text.rawValue].string
            let colorHexInt = UInt32(textJSON[JSONKey.textColor.rawValue].stringValue, radix: 16) ?? 0x000000
            let textColor = UIColor(hex6: colorHexInt)
            let backgroundStyle = Text.BackgroundStyle(
                rawValue: textJSON[JSONKey.backgroundStyle.rawValue].stringValue
            ) ?? .none

            self.text = Text(title: title, text: text, textColor: textColor, backgroundStyle: backgroundStyle)
        }

        let buttonJSON = json[JSONKey.button.rawValue]
        if buttonJSON != JSON.null {
            let title = buttonJSON[JSONKey.title.rawValue].stringValue
            let urlPath = buttonJSON[JSONKey.url.rawValue].stringValue
            let backgroundColorHexInt = UInt32(
                buttonJSON[JSONKey.backgroundColor.rawValue].stringValue,
                radix: 16
            ) ?? 0x000000
            let backgroundColor = UIColor(hex6: backgroundColorHexInt)
            let titleColorHexInt = UInt32(buttonJSON[JSONKey.textColor.rawValue].stringValue, radix: 16) ?? 0x000000
            let titleColor = UIColor(hex6: titleColorHexInt)

            self.button = Button(
                title: title,
                urlPath: urlPath,
                backgroundColor: backgroundColor,
                titleColor: titleColor
            )
        }

        super.init(json: json, storyID: storyID)
    }

    struct Text {
        var title: String?
        var text: String?
        var textColor: UIColor
        var backgroundStyle: BackgroundStyle

        enum BackgroundStyle: String {
            case light
            case dark
            case none

            var backgroundColor: UIColor {
                switch self {
                case .light:
                    return UIColor.white.withAlphaComponent(0.7)
                case .dark:
                    return UIColor.stepikAccentFixed.withAlphaComponent(0.7)
                default:
                    return .clear
                }
            }
        }
    }

    struct Button {
        var title: String
        var urlPath: String
        var backgroundColor: UIColor
        var titleColor: UIColor
    }

    enum JSONKey: String {
        case image
        case text
        case title
        case textColor = "text_color"
        case backgroundStyle = "background_style"
        case button
        case url
        case backgroundColor = "background_color"
    }
}
