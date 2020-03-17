import UIKit

extension UIColor {
    static let mainLight = UIColor(hex6: 0xf6f6f6)

    static var mainText: UIColor { .stepikAccent }

    static let wrongQuizBackground = UIColor(hex6: 0xF5EBF2)
    static let peerReviewYellow = UIColor(hex6: 0xFFFAE9)

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

    static var stepikRed: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.red700,
            dark: ColorPalette.red300,
            lightAccessibility: ColorPalette.red800,
            darkAccessibility: ColorPalette.red200
        )
    }

    static var stepikBlue: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.blue600,
            dark: ColorPalette.blue300,
            lightAccessibility: ColorPalette.blue800,
            darkAccessibility: ColorPalette.blue200
        )
    }

    static var stepikLightBlue: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.lightBlue400,
            dark: ColorPalette.lightBlue200,
            lightAccessibility: ColorPalette.lightBlue600,
            darkAccessibility: ColorPalette.lightBlue100
        )
    }

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

    /// The color for borders or divider lines that hides any underlying content.
    static var stepikSeparator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.opaqueSeparator
        } else {
            return UIColor(hex6: 0xC8C7CC)
        }
    }

    /// The color for activity indicators.
    static var stepikLoadingIndicator: UIColor { .stepikAccent }

    // MARK: - Text Colors -

    /// The color for placeholder text in controls or text views.
    static var stepikPlaceholderText: UIColor { .stepikAccentAlpha40 }
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

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let red800 = UIColor(hex6: 0xC71517)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let red700 = UIColor(hex6: 0xD41F1F)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let red300 = UIColor(hex6: 0xE76D69)
    /// Color to use in dark mode and with a high contrast level.
    static let red200 = UIColor(hex6: 0xF19693)

    // MARK: - Blue -

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let blue800 = UIColor(hex6: 0x3D61C6)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let blue600 = UIColor(hex6: 0x4485ED)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let blue300 = UIColor(hex6: 0x6FB4FE)
    /// Color to use in dark mode and with a high contrast level.
    static let blue200 = UIColor(hex6: 0x97C9FF)

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let lightBlue600 = UIColor(hex6: 0x4487EE)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let lightBlue400 = UIColor(hex6: 0x56A4FF)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
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
}