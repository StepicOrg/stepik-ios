import Foundation

struct SettingsTableViewModel {
    let sections: [SettingsTableSectionViewModel]
}

struct SettingsTableSectionViewModel {
    struct Header {
        let title: String
    }

    struct Cell: UniqueIdentifiable {
        struct Options {
            let topPadding: CGFloat = 0
            let bottomPadding: CGFloat = 0
        }

        let uniqueIdentifier: UniqueIdentifierType
        let type: SettingsTableSectionCellType
        let options: Options

        init(uniqueIdentifier: UniqueIdentifierType, type: SettingsTableSectionCellType, options: Options = .init()) {
            self.uniqueIdentifier = uniqueIdentifier
            self.type = type
            self.options = options
        }
    }

    struct Footer {
        let description: String
    }

    let header: Header?
    let cells: [Cell]
    let footer: Footer?
}

enum SettingsTableSectionCellType {
    case input(options: InputCellOptions)
    case largeInput(options: LargeInputCellOptions)
    case rightDetail(options: RightDetailCellOptions)
}

struct InputCellOptions {
    let shouldAlwaysShowPlaceholder: Bool
    let placeholderText: String?
    let valueText: String?
    let inputGroup: UniqueIdentifierType?
    let isEnabled: Bool

    init(
        valueText: String? = nil,
        placeholderText: String? = nil,
        shouldAlwaysShowPlaceholder: Bool = false,
        inputGroup: UniqueIdentifierType? = nil,
        isEnabled: Bool = true
    ) {
        self.valueText = valueText
        self.placeholderText = placeholderText
        self.shouldAlwaysShowPlaceholder = shouldAlwaysShowPlaceholder
        self.inputGroup = inputGroup
        self.isEnabled = isEnabled
    }
}

struct LargeInputCellOptions {
    let placeholderText: String?
    let valueText: String?
    let maxLength: Int?

    init(
        valueText: String? = nil,
        placeholderText: String? = nil,
        maxLength: Int? = nil
    ) {
        self.valueText = valueText
        self.placeholderText = placeholderText
        self.maxLength = maxLength
    }
}

struct RightDetailCellOptions {
    let title: Title
    let detailType: DetailType
    let accessoryType: UITableViewCell.AccessoryType

    init(
        title: Title,
        detailType: DetailType = .none,
        accessoryType: UITableViewCell.AccessoryType = .none
    ) {
        self.title = title
        self.detailType = detailType
        self.accessoryType = accessoryType
    }

    struct Title {
        let text: String
        let appearance: Appearance

        init(
            text: String,
            appearance: Appearance = .init(textColor: .black, textAlignment: .natural)
        ) {
            self.text = text
            self.appearance = appearance
        }

        struct Appearance {
            let textColor: UIColor
            let textAlignment: NSTextAlignment
        }
    }

    enum DetailType {
        case none
        case label(text: String?)
        case `switch`(isOn: Bool)
    }
}
