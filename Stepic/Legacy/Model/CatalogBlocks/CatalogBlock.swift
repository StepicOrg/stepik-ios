import Foundation
import SwiftyJSON

final class CatalogBlock: JSONSerializable, CustomStringConvertible, Hashable {
    private static let defaultPosition = 1
    private static let defaultLanguage = "en"
    private static let defaultPlatform = PlatformType.ios.rawValue
    private static let defaultIsTitleVisible = true

    var id = 0
    var position = CatalogBlock.defaultPosition
    var title = ""
    var language = CatalogBlock.defaultLanguage
    var platform = CatalogBlock.defaultPlatform
    var descriptionString = ""
    var kindString = ""
    var appearanceString = ""
    var isTitleVisible = CatalogBlock.defaultIsTitleVisible
    var content = [CatalogBlockContentItem]()

    var platformType: PlatformType? { PlatformType(rawValue: self.platform) }
    var kind: CatalogBlockKind? { CatalogBlockKind(rawValue: self.kindString) }
    var appearance: CatalogBlockAppearance? { CatalogBlockAppearance(rawValue: self.appearanceString) }

    var description: String {
        """
        CatalogBlock(id: \(self.id), \
        position: \(self.position), \
        title: \(self.title), \
        language: \(self.language), \
        platform: \(self.platform), \
        description: \(self.descriptionString), \
        kind: \(self.kindString), \
        appearance: \(self.appearanceString), \
        isTitleVisible: \(self.isTitleVisible), \
        content: \(self.content))
        """
    }

    init(
        id: Int,
        position: Int,
        title: String,
        language: String,
        platform: Int,
        descriptionString: String,
        kindString: String,
        appearanceString: String,
        isTitleVisible: Bool,
        content: [CatalogBlockContentItem]
    ) {
        self.id = id
        self.position = position
        self.title = title
        self.language = language
        self.platform = platform
        self.descriptionString = descriptionString
        self.kindString = kindString
        self.appearanceString = appearanceString
        self.isTitleVisible = isTitleVisible
        self.content = content
    }

    init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.position = json[JSONKey.position.rawValue].int ?? Self.defaultPosition
        self.title = json[JSONKey.title.rawValue].stringValue
        self.language = json[JSONKey.language.rawValue].string ?? Self.defaultLanguage
        self.platform = json[JSONKey.platform.rawValue].int ?? Self.defaultPlatform
        self.descriptionString = json[JSONKey.description.rawValue].stringValue
        self.kindString = json[JSONKey.kind.rawValue].stringValue
        self.appearanceString = json[JSONKey.appearance.rawValue].stringValue
        self.isTitleVisible = json[JSONKey.isTitleVisible.rawValue].bool ?? Self.defaultIsTitleVisible
        self.content = json[JSONKey.content.rawValue].arrayValue.compactMap {
            CatalogBlockContentItemParser.parse(json: $0, kind: self.kindString)
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.position)
        hasher.combine(self.title)
        hasher.combine(self.language)
        hasher.combine(self.platform)
        hasher.combine(self.descriptionString)
        hasher.combine(self.kindString)
        hasher.combine(self.appearanceString)
        hasher.combine(self.isTitleVisible)
        hasher.combine(self.content)
    }

    static func == (lhs: CatalogBlock, rhs: CatalogBlock) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.id != rhs.id { return false }
        if lhs.position != rhs.position { return false }
        if lhs.title != rhs.title { return false }
        if lhs.language != rhs.language { return false }
        if lhs.platform != rhs.platform { return false }
        if lhs.descriptionString != rhs.descriptionString { return false }
        if lhs.kindString != rhs.kindString { return false }
        if lhs.appearanceString != rhs.appearanceString { return false }
        if lhs.isTitleVisible != rhs.isTitleVisible { return false }
        if lhs.content != rhs.content { return false }
        return true
    }

    enum JSONKey: String {
        case id
        case position
        case title
        case language
        case platform
        case description
        case kind
        case appearance
        case isTitleVisible = "is_title_visible"
        case content
    }
}
