import Foundation

struct SettingsTableViewModel {
    let sections: [SettingsTableSectionViewModel]
}

struct SettingsTableSectionViewModel {
    struct Header {
        let title: String
    }

    struct Cell: UniqueIdentifiable {
        struct Appearance {
            var backgroundColor: UIColor?
            var selectedBackgroundColor: UIColor?
        }

        let uniqueIdentifier: UniqueIdentifierType
        let type: SettingsTableSectionCellType
        let appearance: Appearance

        init(
            uniqueIdentifier: UniqueIdentifierType,
            type: SettingsTableSectionCellType,
            appearance: Appearance = .init()
        ) {
            self.uniqueIdentifier = uniqueIdentifier
            self.type = type
            self.appearance = appearance
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
        detailType: DetailType = .label(text: nil),
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
            appearance: Appearance = .init(textColor: .stepikSystemPrimaryText, textAlignment: .natural)
        ) {
            self.text = text
            self.appearance = appearance
        }

        struct Appearance {
            let textColor: UIColor
            let textAlignment: NSTextAlignment
        }
    }

    struct Switch {
        let isOn: Bool
        let appearance: Appearance

        init(
            isOn: Bool,
            appearance: Appearance = .init(onTintColor: .stepikSwitchOnTint)
        ) {
            self.isOn = isOn
            self.appearance = appearance
        }

        struct Appearance {
            var onTintColor: UIColor
        }
    }

    struct CheckBox {
        let isOn: Bool
        let checkBoxGroup: UniqueIdentifierType?
        let checkBoxGroupMustHaveSelection: Bool
        let appearance: Appearance

        init(
            isOn: Bool,
            checkBoxGroup: UniqueIdentifierType? = nil,
            checkBoxGroupMustHaveSelection: Bool = false,
            appearance: Appearance = .init()
        ) {
            self.isOn = isOn
            self.checkBoxGroup = checkBoxGroup
            self.checkBoxGroupMustHaveSelection = checkBoxGroupMustHaveSelection
            self.appearance = appearance
        }

        struct Appearance {}
    }

    enum DetailType {
        case label(text: String?)
        case `switch`(Switch)
        case checkBox(CheckBox)
    }
}
