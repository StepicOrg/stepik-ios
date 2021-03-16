import Foundation
import SwiftyJSON

class StoryPart {
    var type: PartType?
    var position: Int
    var duration: Double
    var imagePath: String
    var storyID: Int

    init(json: JSON, storyID: Int) {
        self.type = PartType(rawValue: json[JSONKey.type.rawValue].stringValue)
        self.position = json[JSONKey.position.rawValue].intValue - 1
        self.duration = json[JSONKey.duration.rawValue].doubleValue
        self.imagePath = HTMLProcessor.addStepikURLIfNeeded(url: json[JSONKey.image.rawValue].stringValue)
        self.storyID = storyID
    }

    enum PartType: String {
        case text
        case feedback
    }

    enum JSONKey: String {
        case type
        case position
        case duration
        case image
    }
}

// MARK: - TextStoryPart -

final class TextStoryPart: StoryPart {
    var text: Text?
    var button: Button?

    override init(json: JSON, storyID: Int) {
        let textJSON = json[JSONKey.text.rawValue]
        if textJSON != JSON.null {
            let title = textJSON[JSONKey.title.rawValue].string
            let text = textJSON[JSONKey.text.rawValue].string
            let textColor = Parser.colorFromHex6StringJSON(textJSON[JSONKey.textColor.rawValue]) ?? .black
            let backgroundStyle = Text.BackgroundStyle(
                rawValue: textJSON[JSONKey.backgroundStyle.rawValue].stringValue
            ) ?? .none

            self.text = Text(title: title, text: text, textColor: textColor, backgroundStyle: backgroundStyle)
        }

        let buttonJSON = json[JSONKey.button.rawValue]
        if buttonJSON != JSON.null {
            let title = buttonJSON[JSONKey.title.rawValue].stringValue
            let urlPath = buttonJSON[JSONKey.url.rawValue].stringValue
            let backgroundColor = Parser.colorFromHex6StringJSON(buttonJSON[JSONKey.backgroundColor.rawValue]) ?? .black
            let titleColor = Parser.colorFromHex6StringJSON(buttonJSON[JSONKey.textColor.rawValue]) ?? .black

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
        case text
        case title
        case textColor = "text_color"
        case backgroundStyle = "background_style"
        case button
        case url
        case backgroundColor = "background_color"
    }
}

// MARK: - FeedbackStoryPart -

final class FeedbackStoryPart: StoryPart {
    var text: Text?
    var button: Button?
    var feedback: Feedback?

    override init(json: JSON, storyID: Int) {
        let textJSON = json[JSONKey.text.rawValue]
        if textJSON != JSON.null {
            let title = textJSON[JSONKey.title.rawValue].string
            let textColor = Parser.colorFromHex6StringJSON(
                textJSON[JSONKey.textColor.rawValue]
            ) ?? Text.defaultTextColor

            self.text = Text(title: title, textColor: textColor)
        }

        let buttonJSON = json[JSONKey.button.rawValue]
        if buttonJSON != JSON.null {
            let title = buttonJSON[JSONKey.title.rawValue].stringValue
            let feedbackTitle = buttonJSON[JSONKey.feedbackTitle.rawValue].stringValue

            let backgroundColor = Parser.colorFromHex6StringJSON(
                buttonJSON[JSONKey.backgroundColor.rawValue]
            ) ?? Button.defaultBackgroundColor

            let titleColor = Parser.colorFromHex6StringJSON(
                buttonJSON[JSONKey.textColor.rawValue]
            ) ?? Button.defaultTitleColor

            self.button = Button(
                title: title,
                backgroundColor: backgroundColor,
                titleColor: titleColor,
                feedbackTitle: feedbackTitle
            )
        }

        let feedbackJSON = json[JSONKey.feedback.rawValue]
        if feedbackJSON != JSON.null {
            let text = feedbackJSON[JSONKey.text.rawValue].stringValue
            let textColor = Parser.colorFromHex6StringJSON(
                feedbackJSON[JSONKey.textColor.rawValue]
            ) ?? Feedback.defaultTextColor

            let iconStyle = Feedback.IconStyle(
                rawValue: feedbackJSON[JSONKey.iconStyle.rawValue].stringValue
            ) ?? .default

            let backgroundColor = Parser.colorFromHex6StringJSON(
                feedbackJSON[JSONKey.backgroundColor.rawValue]
            ) ?? Feedback.defaultBackgroundColor

            let inputBackgroundColor = Parser.colorFromHex6StringJSON(
                feedbackJSON[JSONKey.inputBackgroundColor.rawValue]
            ) ?? Feedback.defaultInputBackgroundColor

            let inputTextColor = Parser.colorFromHex6StringJSON(
                feedbackJSON[JSONKey.inputTextColor.rawValue]
            ) ?? Feedback.defaultInputTextColor

            let placeholderText = feedbackJSON[JSONKey.placeholderText.rawValue].stringValue
            let placeholderTextColor = Parser.colorFromHex6StringJSON(
                feedbackJSON[JSONKey.placeholderTextColor.rawValue]
            ) ?? Feedback.defaultPlaceholderTextColor

            self.feedback = Feedback(
                text: text,
                textColor: textColor,
                iconStyle: iconStyle,
                backgroundColor: backgroundColor,
                inputBackgroundColor: inputBackgroundColor,
                inputTextColor: inputTextColor,
                placeholderText: placeholderText,
                placeholderTextColor: placeholderTextColor
            )
        }

        super.init(json: json, storyID: storyID)
    }

    struct Text {
        fileprivate static var defaultTextColor = UIColor.white

        var title: String?
        var textColor: UIColor
    }

    struct Button {
        fileprivate static var defaultBackgroundColor = UIColor.stepikVioletFixed
        fileprivate static var defaultTitleColor = UIColor.white

        var title: String
        var backgroundColor: UIColor
        var titleColor: UIColor
        var feedbackTitle: String
    }

    struct Feedback {
        fileprivate static var defaultTextColor = UIColor.black
        fileprivate static var defaultBackgroundColor = UIColor.white
        fileprivate static var defaultInputBackgroundColor = UIColor.blue.withAlphaComponent(0.12)
        fileprivate static var defaultInputTextColor = UIColor.gray
        fileprivate static var defaultPlaceholderTextColor = UIColor.lightGray

        var text: String
        var textColor: UIColor
        var iconStyle: IconStyle
        var backgroundColor: UIColor

        var inputBackgroundColor: UIColor
        var inputTextColor: UIColor

        var placeholderText: String
        var placeholderTextColor: UIColor

        enum IconStyle: String {
            case light
            case dark

            static var `default`: IconStyle { .dark }

            var image: UIImage? {
                switch self {
                case .light:
                    return UIImage(named: "stories-feedback-comment-light")
                case .dark:
                    return UIImage(named: "stories-feedback-comment-dark")
                }
            }
        }
    }

    enum JSONKey: String {
        case text
        case title
        case button
        case feedback
        case textColor = "text_color"
        case backgroundColor = "background_color"
        case feedbackTitle = "feedback_title"
        case iconStyle = "icon_style"
        case inputBackgroundColor = "input_background_color"
        case inputTextColor = "input_text_color"
        case placeholderText = "placeholder_text"
        case placeholderTextColor = "placeholder_text_color"
    }
}
