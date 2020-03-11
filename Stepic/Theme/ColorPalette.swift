import UIKit

extension UIColor {
    static let errorRed = UIColor(hex6: 0xff0033)

    static let lightBlue = UIColor(hex6: 0x45B0FF)

    static var stepikGreen: UIColor { StepikApplicationsInfo.Colors.mainGreen }

    static let mainLight = UIColor(hex6: 0xf6f6f6)

    static var mainText: UIColor { return StepikApplicationsInfo.Colors.mainText }

    static let thirdColor = UIColor(hex6: 0x54a2ff)

    static let correctQuizBackground = UIColor(hex6: 0xE9F9E9)
    static let wrongQuizBackground = UIColor(hex6: 0xF5EBF2)
    static let peerReviewYellow = UIColor(hex6: 0xFFFAE9)

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

    static var stepikAccentAlpha25: UIColor {
        UIColor.dynamicColor(
            light: ColorPalette.accent700Alpha25,
            dark: ColorPalette.accent300Alpha25,
            lightAccessibility: ColorPalette.accent800Alpha25,
            darkAccessibility: ColorPalette.accent200Alpha25
        )
    }

    // MARK: - Text Colors -

    /// The color for placeholder text in controls or text views.
    static var stepikPlaceholderText: UIColor {
        UIColor.stepikAccentAlpha40
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

    // MARK: Alpha 25

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 25.
    static let accent800Alpha25 = UIColor(hex8: 0x40353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 25.
    static let accent700Alpha25 = UIColor(hex8: 0x40535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 25.
    static let accent300Alpha25 = UIColor(hex8: 0x40D3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 25.
    static let accent200Alpha25 = UIColor(hex8: 0x40E4E4FA)
}
