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
}

struct InputCellOptions {
    let shouldAlwaysShowPlaceholder: Bool
    let placeholderText: String?
    let valueText: String?
    let inputGroup: UniqueIdentifierType?

    init(
        valueText: String? = nil,
        placeholderText: String? = nil,
        shouldAlwaysShowPlaceholder: Bool = false,
        inputGroup: UniqueIdentifierType? = nil
    ) {
        self.valueText = valueText
        self.placeholderText = placeholderText
        self.shouldAlwaysShowPlaceholder = shouldAlwaysShowPlaceholder
        self.inputGroup = inputGroup
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
