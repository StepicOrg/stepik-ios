import Foundation
import Regex

protocol ContentProcessingRule: AnyObject {
    func process(content: String) -> String
}

class BaseHTMLExtractionRule: ContentProcessingRule {
    fileprivate let extractorType: HTMLExtractorProtocol.Type

    init(extractorType: HTMLExtractorProtocol.Type) {
        self.extractorType = extractorType
    }

    /// Just return argument back
    func process(content: String) -> String { content }
}

/// Add default protocol to all protocol relative paths, e.g replace "//site.com" with "http://site.com"
final class FixRelativeProtocolURLsRule: ContentProcessingRule {
    func process(content: String) -> String {
        content.replacingOccurrences(of: "src=\"//", with: "src=\"http://")
    }
}

/// Add Stepik domain to all relative paths, e.g replace "/content" with "http://stepik.org/content"
final class AddStepikSiteForRelativeURLsRule: BaseHTMLExtractionRule {
    override func process(content: String) -> String {
        let links = self.extractorType.extractAllTagsAttribute(tag: "a", attribute: "href", from: content)
            + self.extractorType.extractAllTagsAttribute(tag: "img", attribute: "src", from: content)

        var content = content
        for link in Array(Set(links)) {
            let wrappedLink = self.wrapLinkIfNeeded(link)
            if wrappedLink != link {
                content = content.replacingOccurrences(of: "\"\(link)", with: "\"\(wrappedLink)")
            }
        }

        return content
    }

    private func wrapLinkIfNeeded(_ link: String) -> String {
        guard link.first == "/" else {
            return link
        }

        if link.prefix(2) == "//" {
            // Protocol relative URL
            return link
        }

        return "\(StepikApplicationsInfo.stepikURL)\(link)"
    }
}

/// Remove image fixed height
final class RemoveImageFixedHeightRule: BaseHTMLExtractionRule {
    override func process(content: String) -> String {
        var content = content

        let images = self.extractorType.extractAllTags(tag: "img", from: content)
        for image in images {
            var replacedImage = image
            if let regex = try? Regex(string: "(height=\"\\d+\")", options: [.ignoreCase]) {
                replacedImage.replaceFirst(matching: regex, with: "")
            }
            replacedImage = replacedImage.condenseWhitespace()

            content = content.replacingOccurrences(of: image, with: replacedImage)
        }
        return content
    }
}

final class ReplaceImageSourceWithBase64Rule: BaseHTMLExtractionRule {
    private let base64EncodedStringByImageURL: [URL: String]

    init(base64EncodedStringByImageURL: [URL: String], extractorType: HTMLExtractorProtocol.Type) {
        self.base64EncodedStringByImageURL = base64EncodedStringByImageURL
        super.init(extractorType: extractorType)
    }

    override func process(content: String) -> String {
        var content = content

        let images = self.extractorType.extractAllTags(tag: "img", from: content)
        let urlStrings = self.extractorType.extractAllTagsAttribute(tag: "img", attribute: "src", from: content)

        for (image, urlString) in zip(images, urlStrings) {
            guard let imageURL = URL(string: urlString),
                  let base64EncodedString = self.base64EncodedStringByImageURL[imageURL] else {
                continue
            }

            var replacedImage = image

            if let regex = try? Regex(string: "(src=\".*\")", options: [.ignoreCase]) {
                replacedImage.replaceFirst(
                    matching: regex,
                    with: "src=\"data:image/jpg;base64, \(base64EncodedString)\""
                )
            }
            replacedImage = replacedImage.condenseWhitespace()

            content = content.replacingOccurrences(of: image, with: replacedImage)
        }

        return content
    }
}

final class ReplaceModelViewerWithARImageRule: BaseHTMLExtractionRule {
    override func process(content: String) -> String {
        var content = content

        let modelViewerTagName = "model-viewer"
        let modelViewerTags = self.extractorType.extractAllTags(tag: modelViewerTagName, from: content)

        for tag in modelViewerTags {
            let thumbnailAttributes = self.extractorType.extractAllTagsAttribute(
                tag: modelViewerTagName,
                attribute: "thumbnail",
                from: tag
            )
            let iOSSourceAttributes = self.extractorType.extractAllTagsAttribute(
                tag: modelViewerTagName,
                attribute: "ios-src",
                from: tag
            )
            let altAttributes = self.extractorType.extractAllTagsAttribute(
                tag: modelViewerTagName,
                attribute: "alt",
                from: tag
            )

            guard let thumbnailURLString = thumbnailAttributes.first,
                  let usdzFileURLString = iOSSourceAttributes.first else {
                continue
            }

            let altAttributeValue: String = {
                if let altAttribute = altAttributes.first {
                    return altAttribute
                }
                return NSLocalizedString("StepARThumbnailALTText", comment: "")
            }()

            let clickableARImageTag = """
            <a href="openar://\(usdzFileURLString)">
                <div style="position:relative;padding-bottom:56.25%;overflow:hidden;border-radius:10px;">
                    <div style="position:absolute;background-color:#CCCCCC4D;width:100%;height:100%;z-index:1;"></div>
                    <img src="\(thumbnailURLString)" alt="\(altAttributeValue)" style="position:absolute;object-fit:cover;width:100%;height:100%;" ar-thumbnail>
                    <div style="position:absolute;top:10px;right:10px;z-index:2;">
                        <img src="ARKit-Badge-Glyph-Only.png" width="39" height="39">
                    </div>
                </div>
            </a>
            """

            content = content.replacingOccurrences(of: tag, with: clickableARImageTag)
        }

        return content
    }
}

/// Makes the contents of the <details> element visible and prevents toggle behavior.
final class AlwaysOpenedDetailsDisclosureBoxRule: ContentProcessingRule {
    func process(content: String) -> String {
        content.replacingOccurrences(of: "<details>", with: "<details open onclick=\"return false\">")
    }
}

final class ReplaceTemplateUsernameRule: ContentProcessingRule {
    private let shortName: String
    private let fullName: String

    init(shortName: String, fullName: String) {
        self.shortName = shortName
        self.fullName = fullName
    }

    func process(content: String) -> String {
        guard let shortRegex = try? Regex(string: "\\{\\{\\s*user_name\\s*\\}\\}", options: [.ignoreCase]),
              let fullRegex = try? Regex(string: "\\{\\{\\s*user_full_name\\s*\\}\\}", options: [.ignoreCase]) else {
            return content
        }

        var content = content

        content.replaceAll(matching: shortRegex, with: self.shortName)
        content.replaceAll(matching: fullRegex, with: self.fullName)

        return content
    }
}
