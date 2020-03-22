import UIKit

extension UIColor {
    // MARK: - Brand Colors -

    // MARK: Green

    static var stepikGreen: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.green400,
            dark: ColorPalette.green300,
            lightAccessibility: ColorPalette.green500,
            darkAccessibility: ColorPalette.green200
        )
    }

    static var stepikLightGreen: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.lightGreen50,
            dark: ColorPalette.lightGreen50,
            lightAccessibility: ColorPalette.lightGreen200,
            darkAccessibility: ColorPalette.lightGreen200
        )
    }

    static var stepikDarkGreen: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.darkGreen500,
            dark: ColorPalette.darkGreen300,
            lightAccessibility: ColorPalette.darkGreen600,
            darkAccessibility: ColorPalette.darkGreen200
        )
    }

    // MARK: Red

    static var stepikRed: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.red700,
            dark: ColorPalette.red300,
            lightAccessibility: ColorPalette.red800,
            darkAccessibility: ColorPalette.red200
        )
    }

    static var stepikLightRed: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.lightRed50,
            dark: ColorPalette.lightRed50,
            lightAccessibility: ColorPalette.lightRed200,
            darkAccessibility: ColorPalette.lightRed200
        )
    }

    // MARK: Blue

    static var stepikBlue: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.blue600,
            dark: ColorPalette.blue300,
            lightAccessibility: ColorPalette.blue700,
            darkAccessibility: ColorPalette.blue200
        )
    }

    static var stepikLightBlue: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.lightBlue400,
            dark: ColorPalette.lightBlue300,
            lightAccessibility: ColorPalette.lightBlue500,
            darkAccessibility: ColorPalette.lightBlue200
        )
    }

    // MARK: Yellow

    static var stepikYellow: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.yellow600,
            dark: ColorPalette.yellow300,
            lightAccessibility: ColorPalette.yellow700,
            darkAccessibility: ColorPalette.yellow200
        )
    }

    // MARK: Grey

    static var stepikGrey: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.grey100,
            dark: ColorPalette.grey050,
            lightAccessibility: ColorPalette.grey200
        )
    }

    // MARK: Accent

    /// A non adaptable color with hex value #535366.
    static var stepikAccentFixed: UIColor { ColorPalette.accent700 }

    static var stepikAccent: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.accent700,
            dark: ColorPalette.accent300,
            lightAccessibility: ColorPalette.accent800,
            darkAccessibility: ColorPalette.accent200
        )
    }

    static var stepikAccentAlpha85: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.accent700Alpha85,
            dark: ColorPalette.accent300Alpha85,
            lightAccessibility: ColorPalette.accent800Alpha85,
            darkAccessibility: ColorPalette.accent200Alpha85
        )
    }

    static var stepikAccentAlpha70: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.accent700Alpha70,
            dark: ColorPalette.accent300Alpha70,
            lightAccessibility: ColorPalette.accent800Alpha70,
            darkAccessibility: ColorPalette.accent200Alpha70
        )
    }

    static var stepikAccentAlpha50: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.accent700Alpha50,
            dark: ColorPalette.accent300Alpha50,
            lightAccessibility: ColorPalette.accent800Alpha50,
            darkAccessibility: ColorPalette.accent200Alpha50
        )
    }

    static var stepikAccentAlpha40: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.accent700Alpha40,
            dark: ColorPalette.accent300Alpha40,
            lightAccessibility: ColorPalette.accent800Alpha40,
            darkAccessibility: ColorPalette.accent200Alpha40
        )
    }

    static var stepikAccentAlpha30: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.accent700Alpha30,
            dark: ColorPalette.accent300Alpha30,
            lightAccessibility: ColorPalette.accent800Alpha30,
            darkAccessibility: ColorPalette.accent200Alpha30
        )
    }

    static var stepikAccentAlpha25: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.accent700Alpha25,
            dark: ColorPalette.accent300Alpha25,
            lightAccessibility: ColorPalette.accent800Alpha25,
            darkAccessibility: ColorPalette.accent200Alpha25
        )
    }

    static var stepikAccentAlpha06: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.accent700Alpha06,
            dark: ColorPalette.accent300Alpha06,
            lightAccessibility: ColorPalette.accent800Alpha06,
            darkAccessibility: ColorPalette.accent200Alpha06
        )
    }

    // MARK: - UI Element Colors -

    /// The color for borders or divider lines that hides any underlying content.
    static var stepikSeparator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.opaqueSeparator
        } else {
            return UIColor(hex6: 0xC8C7CC)
        }
    }

    /// The color for text labels that contain primary content.
    /// Black in light mode and white in dark mode.
    static var stepikSystemLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }

    /// The color for text labels that contain secondary content.
    static var stepikSystemSecondaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return UIColor(hex8: 0x993C3C43)
        }
    }

    /// The color for text labels that contain tertiary content.
    static var stepikSystemTertiaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiaryLabel
        } else {
            return UIColor(hex8: 0x4C3C3C43)
        }
    }

    /// The color for text labels that contain quaternary content.
    static var stepikSystemQuaternaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .quaternaryLabel
        } else {
            return UIColor(hex8: 0x2D3C3C43)
        }
    }

    /// The color for activity indicators.
    static var stepikLoadingIndicator: UIColor { .stepikAccent }

    // MARK: Text Colors

    /// The color for texts that contain primary content.
    static var stepikPrimaryText: UIColor { .stepikAccent }

    /// The color for placeholder text in controls or text views.
    static var stepikPlaceholderText: UIColor { .stepikAccentAlpha40 }

    // MARK: Standard Content Background Colors

    /// The color for the main background of the interface.
    static var stepikBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    /// The color for content layered on top of the main background.
    static var stepikSecondaryBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemBackground
        } else {
            return UIColor(hex6: 0xF2F2F7)
        }
    }

    /// The color for content layered on top of secondary backgrounds.
    static var stepikTertiaryBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiarySystemBackground
        } else {
            return .white
        }
    }

    /// The color to use for the background of a grouped table.
    static var stepikGroupTableViewBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGroupedBackground
        } else {
            return .groupTableViewBackground
        }
    }

    // MARK: Standard Colors

    /// The base gray color.
    static var stepikGray: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray
        } else {
            return UIColor(hex6: 0x8E8E93)
        }
    }

    /// A second-level shade of grey.
    static var stepikGray2: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray2
        } else {
            return UIColor(hex6: 0xAEAEB2)
        }
    }
}

// MARK: - ColorPalette -

private enum ColorPalette {
    // MARK: - Accent Color -

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let accent800 = UIColor(hex6: 0x353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let accent700 = UIColor(hex6: 0x535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let accent300 = UIColor(hex6: 0xD3D2E9)
    /// Color to use in dark mode and with a high contrast level.
    static let accent200 = UIColor(hex6: 0xE4E4FA)

    // MARK: Alpha 85

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 85.
    static let accent800Alpha85 = UIColor(hex8: 0xD9353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 85.
    static let accent700Alpha85 = UIColor(hex8: 0xD9535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 85.
    static let accent300Alpha85 = UIColor(hex8: 0xD9D3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 85.
    static let accent200Alpha85 = UIColor(hex8: 0xD9E4E4FA)

    // MARK: Alpha 70

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 70.
    static let accent800Alpha70 = UIColor(hex8: 0xB3353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 70.
    static let accent700Alpha70 = UIColor(hex8: 0xB3535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 70.
    static let accent300Alpha70 = UIColor(hex8: 0xB3D3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 70.
    static let accent200Alpha70 = UIColor(hex8: 0xB3E4E4FA)

    // MARK: Alpha 50

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 50.
    static let accent800Alpha50 = UIColor(hex8: 0x80353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 50.
    static let accent700Alpha50 = UIColor(hex8: 0x80535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 50.
    static let accent300Alpha50 = UIColor(hex8: 0x80D3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 50.
    static let accent200Alpha50 = UIColor(hex8: 0x80E4E4FA)

    // MARK: Alpha 40

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 40.
    static let accent800Alpha40 = UIColor(hex8: 0x66353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 40.
    static let accent700Alpha40 = UIColor(hex8: 0x66535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 40.
    static let accent300Alpha40 = UIColor(hex8: 0x66D3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 40.
    static let accent200Alpha40 = UIColor(hex8: 0x66E4E4FA)

    // MARK: Alpha 30

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 30.
    static let accent800Alpha30 = UIColor(hex8: 0x4D353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 30.
    static let accent700Alpha30 = UIColor(hex8: 0x4D535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 30.
    static let accent300Alpha30 = UIColor(hex8: 0x4DD3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 30.
    static let accent200Alpha30 = UIColor(hex8: 0x4DE4E4FA)

    // MARK: Alpha 25

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 25.
    static let accent800Alpha25 = UIColor(hex8: 0x40353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 25.
    static let accent700Alpha25 = UIColor(hex8: 0x40535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 25.
    static let accent300Alpha25 = UIColor(hex8: 0x40D3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 25.
    static let accent200Alpha25 = UIColor(hex8: 0x40E4E4FA)

    // MARK: Alpha 6

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 6.
    static let accent800Alpha06 = UIColor(hex8: 0x0F353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 6.
    static let accent700Alpha06 = UIColor(hex8: 0x0F535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 6.
    static let accent300Alpha06 = UIColor(hex8: 0x0FD3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 6.
    static let accent200Alpha06 = UIColor(hex8: 0x0FE4E4FA)

    // MARK: - Red -

    // MARK: Normal

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let red800 = UIColor(hex6: 0xC71517)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let red700 = UIColor(hex6: 0xD41F1F)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let red300 = UIColor(hex6: 0xE76D69)
    /// Color to use in dark mode and with a high contrast level.
    static let red200 = UIColor(hex6: 0xF19693)

    // MARK: Light

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let lightRed200 = UIColor(hex6: 0xFFB596)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let lightRed50 = UIColor(hex6: 0xFFEBE8)

    // MARK: - Blue -

    // MARK: Normal

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let blue700 = UIColor(hex6: 0x4072D9)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let blue600 = UIColor(hex6: 0x4485ED)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let blue300 = UIColor(hex6: 0x6FB4FE)
    /// Color to use in dark mode and with a high contrast level.
    static let blue200 = UIColor(hex6: 0x97C9FF)

    // MARK: Light

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let lightBlue500 = UIColor(hex6: 0x4595FD)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let lightBlue400 = UIColor(hex6: 0x56A4FF)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let lightBlue300 = UIColor(hex6: 0x70B5FF)
    /// Color to use in dark mode and with a high contrast level.
    static let lightBlue200 = UIColor(hex6: 0x97CAFF)

    // MARK: - Green -

    // MARK: Normal

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let green500 = UIColor(hex6: 0x49C249)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let green400 = UIColor(hex6: 0x66CC66)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let green300 = UIColor(hex6: 0x83D683)
    /// Color to use in dark mode and with a high contrast level.
    static let green200 = UIColor(hex6: 0xA8E1A7)

    // MARK: Light

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let lightGreen200 = UIColor(hex6: 0xB1E4AE)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let lightGreen50 = UIColor(hex6: 0xE9F9E9)

    // MARK: Dark

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let darkGreen600 = UIColor(hex6: 0x4B9E4B)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let darkGreen500 = UIColor(hex6: 0x54AD54)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let darkGreen300 = UIColor(hex6: 0x85C586)
    /// Color to use in dark mode and with a high contrast level.
    static let darkGreen200 = UIColor(hex6: 0xA7D5A8)

    // MARK: - Yellow -

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let yellow700 = UIColor(hex6: 0xFCC439)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let yellow600 = UIColor(hex6: 0xFEDB41)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let yellow300 = UIColor(hex6: 0xFDF17A)
    /// Color to use in dark mode and with a high contrast level.
    static let yellow200 = UIColor(hex6: 0xFEF5A0)

    // MARK: - Grey -

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let grey200 = UIColor(hex6: 0xF0F0F0)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let grey100 = UIColor(hex6: 0xF6F6F6)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let grey050 = UIColor(hex6: 0xFAFAFA)
}
