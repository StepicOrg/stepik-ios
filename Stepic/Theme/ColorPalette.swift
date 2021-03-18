import UIKit

extension UIColor {
    // MARK: - Standard Colors -
    // The standard color objects for specific shades, such as red, blue, green, black, white, and more.

    // MARK: - Stepik Standard Colors
    // MARK: Green

    /// Adaptable color with base hex value #66CC66 (green01).
    static var stepikGreen: UIColor {
        .dynamic(
            light: ColorPalette.green400,
            dark: ColorPalette.green300,
            lightAccessibility: ColorPalette.green500,
            darkAccessibility: ColorPalette.green200
        )
    }

    /// Adaptable color with base hex value #E9F9E9 (green06).
    static var stepikLightGreen: UIColor {
        .dynamic(
            light: ColorPalette.lightGreen50,
            dark: ColorPalette.lightGreen50,
            lightAccessibility: ColorPalette.lightGreen200,
            darkAccessibility: ColorPalette.lightGreen200
        )
    }

    /// Adaptable color with base hex value #54AD54 (green03).
    static var stepikDarkGreen: UIColor {
        .dynamic(
            light: ColorPalette.darkGreen500,
            dark: ColorPalette.darkGreen300,
            lightAccessibility: ColorPalette.darkGreen600,
            darkAccessibility: ColorPalette.darkGreen200
        )
    }

    /// A non adaptable color with hex value #66CC66.
    static let stepikGreenFixed = ColorPalette.green400
    /// A non adaptable color with hex value #E9F9E9.
    static let stepikLightGreenFixed = ColorPalette.lightGreen50
    /// A non adaptable color with hex value #54AD54.
    static let stepikDarkGreenFixed = ColorPalette.darkGreen500

    // MARK: Red

    /// Adaptable color with base hex value #D41F1F (red00).
    static var stepikRed: UIColor {
        .dynamic(
            light: ColorPalette.red700,
            dark: ColorPalette.red300,
            lightAccessibility: ColorPalette.red800,
            darkAccessibility: ColorPalette.red200
        )
    }

    /// Adaptable color with base hex value #FF7965 (red01).
    static var stepikLightRed: UIColor {
        .dynamic(
            light: ColorPalette.lightRed300,
            dark: ColorPalette.lightRed200,
            lightAccessibility: ColorPalette.lightRed400,
            darkAccessibility: ColorPalette.lightRed100
        )
    }

    /// Adaptable color with base hex value #FFEBE8 (red02).
    static var stepikExtraLightRed: UIColor {
        .dynamic(
            light: ColorPalette.extraLightRed50,
            dark: ColorPalette.extraLightRed50,
            lightAccessibility: ColorPalette.extraLightRed200,
            darkAccessibility: ColorPalette.extraLightRed200
        )
    }

    /// A non adaptable color with hex value #D41F1F (red00).
    static let stepikRedFixed = ColorPalette.red700
    /// A non adaptable color with hex value #FF7965 (red01).
    static let stepikLightRedFixed = ColorPalette.lightRed300
    /// A non adaptable color with hex value #FFEBE8 (red02).
    static let stepikExtraLightRedFixed = ColorPalette.extraLightRed50

    // MARK: Blue

    /// Adaptable color with base hex value #4485ED (blue05).
    static var stepikBlue: UIColor {
        .dynamic(
            light: ColorPalette.blue600,
            dark: ColorPalette.blue300,
            lightAccessibility: ColorPalette.blue700,
            darkAccessibility: ColorPalette.blue200
        )
    }

    /// Adaptable color with base hex value #56A4FF (blue03).
    static var stepikLightBlue: UIColor {
        .dynamic(
            light: ColorPalette.lightBlue400,
            dark: ColorPalette.lightBlue300,
            lightAccessibility: ColorPalette.lightBlue500,
            darkAccessibility: ColorPalette.lightBlue200
        )
    }

    /// A non adaptable color with hex value #4485ED (blue05).
    static let stepikBlueFixed = ColorPalette.blue600
    /// A non adaptable color with hex value #56A4FF (blue03).
    static let stepikLightBlueFixed = ColorPalette.lightBlue400

    // MARK: Yellow

    /// Adaptable color with base hex value #FEDB41 (yellow02).
    static var stepikYellow: UIColor {
        .dynamic(
            light: ColorPalette.yellow600,
            dark: ColorPalette.yellow300,
            lightAccessibility: ColorPalette.yellow700,
            darkAccessibility: ColorPalette.yellow200
        )
    }

    /// Adaptable color with base hex value #FFF6E5 (yellow03).
    static var stepikLightYellow: UIColor {
        .dynamic(
            light: ColorPalette.lightYellow50,
            dark: ColorPalette.lightYellow300,
            lightAccessibility: ColorPalette.lightYellow100,
            darkAccessibility: ColorPalette.lightYellow200
        )
    }

    /// Adaptable color with base hex value #FEA832 (yellow01).
    static var stepikDarkYellow: UIColor {
        .dynamic(
            light: ColorPalette.darkYellow400,
            dark: ColorPalette.darkYellow300,
            lightAccessibility: ColorPalette.darkYellow500,
            darkAccessibility: ColorPalette.darkYellow200
        )
    }

    /// A non adaptable color with hex value #FEDB41 (yellow02).
    static let stepikYellowFixed = ColorPalette.yellow600
    /// A non adaptable color with hex value #FEDB41 (yellow03).
    static let stepikLightYellowFixed = ColorPalette.lightYellow50
    /// A non adaptable color with hex value #FEDB41 (yellow01).
    static let stepikDarkYellowFixed = ColorPalette.darkYellow400

    // MARK: Grey

    /// Adaptable color with base hex value #F6F6F6 (grey07).
    static var stepikGrey: UIColor {
        .dynamic(
            light: ColorPalette.grey100,
            dark: ColorPalette.grey050,
            lightAccessibility: ColorPalette.grey200
        )
    }

    /// A non adaptable color with hex value #F6F6F6 (grey07).
    static let stepikGreyFixed = ColorPalette.grey100
    /// A non adaptable color with hex value #EAEAEA (grey08).
    static let stepikGrey8Fixed = ColorPalette.grey08

    // MARK: Violet

    /// A non adaptable color with hex value #6C7BDF (violet01).
    static let stepikVioletFixed = ColorPalette.violet01
    /// A non adaptable color with hex value #9CA6E6 (violet03).
    static let stepikLightVioletFixed = ColorPalette.violet03
    /// A non adaptable color with hex value #E9EBFA (violet02).
    static let stepikExtraLightVioletFixed = ColorPalette.violet02
    /// A non adaptable color with hex value #3E50CB (violet04).
    static let stepikDarkVioletFixed = ColorPalette.violet04
    /// A non adaptable color with hex value #98A0E8 (violet05).
    static let stepikViolet05Fixed = ColorPalette.violet05

    // MARK: Orange

    /// Adaptable color with base hex value #FFA861.
    static var stepikOrange: UIColor {
        .dynamic(
            light: ColorPalette.orange800,
            dark: ColorPalette.orange500,
            lightAccessibility: ColorPalette.orange900,
            darkAccessibility: ColorPalette.orange400
        )
    }

    // MARK: Accent (grey06)

    /// Adaptable color with base hex value #535366 (grey06).
    static var stepikAccent: UIColor {
        .dynamic(
            light: ColorPalette.accent700,
            dark: ColorPalette.accent300,
            lightAccessibility: ColorPalette.accent800,
            darkAccessibility: ColorPalette.accent200
        )
    }

    /// Adaptable color with base hex value #535366 and the opacity value of the 0.60 (grey06).
    static var stepikAccentAlpha60: UIColor {
        .dynamic(
            light: ColorPalette.accent700Alpha60,
            dark: ColorPalette.accent300Alpha60,
            lightAccessibility: ColorPalette.accent800Alpha60,
            darkAccessibility: ColorPalette.accent200Alpha60
        )
    }

    /// Adaptable color with base hex value #535366 and the opacity value of the 0.50 (grey06).
    static var stepikAccentAlpha50: UIColor {
        .dynamic(
            light: ColorPalette.accent700Alpha50,
            dark: ColorPalette.accent300Alpha50,
            lightAccessibility: ColorPalette.accent800Alpha50,
            darkAccessibility: ColorPalette.accent200Alpha50
        )
    }

    /// Adaptable color with base hex value #535366 and the opacity value of the 0.40 (grey06).
    static var stepikAccentAlpha40: UIColor {
        .dynamic(
            light: ColorPalette.accent700Alpha40,
            dark: ColorPalette.accent300Alpha40,
            lightAccessibility: ColorPalette.accent800Alpha40,
            darkAccessibility: ColorPalette.accent200Alpha40
        )
    }

    /// Adaptable color with base hex value #535366 and the opacity value of the 0.30 (grey06).
    static var stepikAccentAlpha30: UIColor {
        .dynamic(
            light: ColorPalette.accent700Alpha30,
            dark: ColorPalette.accent300Alpha30,
            lightAccessibility: ColorPalette.accent800Alpha30,
            darkAccessibility: ColorPalette.accent200Alpha30
        )
    }

    /// Adaptable color with base hex value #535366 and the opacity value of the 0.25 (grey06).
    static var stepikAccentAlpha25: UIColor {
        .dynamic(
            light: ColorPalette.accent700Alpha25,
            dark: ColorPalette.accent300Alpha25,
            lightAccessibility: ColorPalette.accent800Alpha25,
            darkAccessibility: ColorPalette.accent200Alpha25
        )
    }

    /// Adaptable color with base hex value #535366 and the opacity value of the 0.18 (grey06).
    static var stepikAccentAlpha18: UIColor {
        .dynamic(
            light: ColorPalette.accent700Alpha18,
            dark: ColorPalette.accent300Alpha18,
            lightAccessibility: ColorPalette.accent800Alpha18,
            darkAccessibility: ColorPalette.accent200Alpha18
        )
    }

    /// A non adaptable color with hex value #535366 (grey06).
    static let stepikAccentFixed = ColorPalette.accent700
    /// A non adaptable color with hex value #282B41 (darkblue01).
    static let stepikDarkAccentFixed = ColorPalette.darkAccent900
    /// A non adaptable color with hex value #222437 (darkblue02).
    static let stepikExtraDarkAccentFixed = ColorPalette.extraDarkAccent900

    // MARK: - Material Color Theme -

    static let onSurface = UIColor.dynamic(light: .black, dark: .white)

    /// The material color for text labels that contain primary content.
    ///
    /// `OnSurface_0.87`
    static var stepikMaterialPrimaryText: UIColor {
        UIColor.onSurface.withAlphaComponent(0.87)
    }

    /// The material color for text labels that contain secondary content.
    ///
    /// `OnSurface_0.6`
    static var stepikMaterialSecondaryText: UIColor {
        UIColor.onSurface.withAlphaComponent(0.6)
    }

    /// The material color for text labels that contain disabled content.
    ///
    /// `OnSurface_0.38`
    static var stepikMaterialDisabledText: UIColor {
        UIColor.onSurface.withAlphaComponent(0.38)
    }

    // MARK: - System Standard Colors

    /// The base gray color.
    static var stepikSystemGray: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray
        } else {
            return UIColor(hex6: 0x8E8E93)
        }
    }

    /// A second-level shade of grey.
    static var stepikSystemGray2: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray2
        } else {
            return UIColor(hex6: 0xAEAEB2)
        }
    }

    // MARK: - UI Element Colors -
    // The standard color objects for labels, text, backgrounds, links, and more.

    /// The color for thin borders or divider lines that allows some underlying content to be visible.
    static var stepikSeparator: UIColor {
        if #available(iOS 13.0, *) {
            return .separator
        } else {
            return UIColor(hex8: 0x99545458)
        }
    }

    /// The color for borders or divider lines that hides any underlying content.
    static var stepikOpaqueSeparator: UIColor {
        if #available(iOS 13.0, *) {
            return .opaqueSeparator
        } else {
            return UIColor(hex6: 0xC8C7CC)
        }
    }

    /// A non adaptable color for shadow views with hex value #EAECF0 (grey04).
    static let stepikShadowFixed = ColorPalette.grey04

    /// The color for activity indicators.
    static var stepikLoadingIndicator: UIColor { .stepikAccent }

    /// The color used to tint the appearance of the switch when it is turned on.
    static var stepikSwitchOnTint: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                traitCollection.userInterfaceStyle == .dark && traitCollection.userInterfaceLevel == .elevated
                    ? .stepikAccentFixed
                    : .stepikAccent
            }
        } else {
            return .stepikAccentFixed
        }
    }

    // MARK: Text Colors

    /// The color for texts that contain primary content.
    static var stepikPrimaryText: UIColor { .stepikAccent }

    /// The color for texts that contain secondary content.
    static var stepikSecondaryText: UIColor { .stepikAccentAlpha60 }

    /// The color for texts that contain tertiary content.
    static var stepikTertiaryText: UIColor { .stepikAccentAlpha30 }

    /// The color for texts that contain quaternary content.
    static var stepikQuaternaryText: UIColor { .stepikAccentAlpha18 }

    /// The color for placeholder text in controls or text views.
    static var stepikPlaceholderText: UIColor { .stepikAccentAlpha40 }

    /// The system color for text labels that contain primary content.
    static var stepikSystemPrimaryText: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }

    /// The system color for text labels that contain secondary content.
    static var stepikSystemSecondaryText: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return UIColor(hex8: 0x993C3C43)
        }
    }

    /// The system color for text labels that contain tertiary content.
    static var stepikSystemTertiaryText: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiaryLabel
        } else {
            return UIColor(hex8: 0x4C3C3C43)
        }
    }

    /// The system color for text labels that contain quaternary content.
    static var stepikSystemQuaternaryText: UIColor {
        if #available(iOS 13.0, *) {
            return .quaternaryLabel
        } else {
            return UIColor(hex8: 0x2D3C3C43)
        }
    }

    /// The system color for placeholder text in controls or text views.
    static var stepikSystemPlaceholderText: UIColor {
        if #available(iOS 13.0, *) {
            return .placeholderText
        } else {
            return UIColor(hex8: 0x4C3C3C43)
        }
    }

    // MARK: Other Text Colors

    /// The color for texts that calls to action (join course, sign in...).
    static var stepikCallToActionText: UIColor { .stepikGreen }

    static var stepikGradientCoursesBluePlaceholderText: UIColor {
        .dynamic(
            light: ColorPalette.gradientCoursesBlue900,
            dark: ColorPalette.gradientCoursesBlue200,
            lightAccessibility: ColorPalette.gradientCoursesBlue900,
            darkAccessibility: ColorPalette.gradientCoursesBlue100
        )
    }

    static var stepikGradientCoursesPinkPlaceholderText: UIColor {
        .dynamic(
            light: ColorPalette.gradientCoursesPink900,
            dark: ColorPalette.gradientCoursesPink200,
            lightAccessibility: ColorPalette.gradientCoursesPink900,
            darkAccessibility: ColorPalette.gradientCoursesPink100
        )
    }

    // MARK: Standard Content Background Colors
    // Colors for standard table views and designs that have a white primary background in a light environment.

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

    /// The color for content layered on top of the main background.
    static var stepikLightSecondaryBackground: UIColor {
        .dynamic(light: ColorPalette.grey100, dark: .stepikSecondaryBackground)
    }

    /// The color for content layered on top of secondary backgrounds.
    static var stepikTertiaryBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiarySystemBackground
        } else {
            return .white
        }
    }

    // MARK: Grouped Content Background Colors
    // Colors for grouped content, including table views and platter-based designs.

    /// The color for the main background of grouped interface.
    static var stepikGroupedBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGroupedBackground
        } else {
            return .groupTableViewBackground
        }
    }

    /// The color for content layered on top of the main background of grouped interface.
    static var stepikSecondaryGroupedBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemGroupedBackground
        } else {
            return .white
        }
    }

    /// The color for content layered on top of secondary backgrounds of grouped interface.
    static var stepikTertiaryGroupedBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiarySystemGroupedBackground
        } else {
            return UIColor(hex6: 0xF2F2F7)
        }
    }

    // MARK: Other Content Background Colors

    /// The color to use for the background of a navigation bar.
    static var stepikNavigationBarBackground: UIColor {
        .dynamic(light: ColorPalette.grey100, dark: UIColor(hex6: 0x121212))
    }

    /// The color to use for the background of a tab bar.
    static var stepikTabBarBackground: UIColor { .stepikNavigationBarBackground }

    /// The color to use for the background of a alert.
    static var stepikAlertBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemBackground
        } else {
            return .white
        }
    }

    /// The color to use for the call to action background (join course, sign in...).
    static var stepikCallToActionBackground: UIColor { UIColor.stepikGreen.withAlphaComponent(0.1) }

    /// The color to use for the content overlay (intro video overlay).
    static var stepikOverlayBackground: UIColor {
        .dynamic(light: .stepikAccentAlpha40, dark: UIColor.stepikSecondaryBackground.withAlphaComponent(0.4))
    }

    /// The color to use for the content overlay with violet.
    static var stepikOverlayViolet: UIColor {
        .dynamic(
            light: UIColor.stepikVioletFixed.withAlphaComponent(0.12),
            dark: ColorPalette.violet05.withAlphaComponent(0.12)
        )
    }

    // MARK: - Skeleton Gradient -

    static var skeletonGradientFirst: UIColor {
        .dynamic(light: ColorPalette.grey100, dark: .stepikSecondaryBackground)
    }

    static var skeletonGradientSecond: UIColor {
        .dynamic(light: UIColor(hex6: 0xE7E7E7), dark: .stepikTertiaryBackground)
    }

    // MARK: - Quizzes -

    // MARK: Fill

    static var quizElementDefaultBackground: UIColor {
        .dynamic(light: .stepikBackground, dark: .stepikSecondaryBackground)
    }

    static var quizElementCorrectBackground: UIColor {
        .dynamic(light: .stepikLightGreen, dark: .stepikCallToActionBackground)
    }

    static var quizElementPartiallyCorrectBackground: UIColor {
        .dynamic(
            light: .stepikLightYellow,
            dark: UIColor.stepikLightYellow.withAlphaComponent(0.1)
        )
    }

    static var quizElementWrongBackground: UIColor {
        .dynamic(
            light: UIColor.stepikLightRed.withAlphaComponent(0.15),
            dark: UIColor.stepikRed.withAlphaComponent(0.1)
        )
    }

    static var quizElementSelectedBackground: UIColor {
        .dynamic(
            light: .stepikExtraLightVioletFixed,
            dark: UIColor.stepikExtraLightVioletFixed.withAlphaComponent(0.1)
        )
    }

    // MARK: Border

    static var quizElementDefaultBorder: UIColor { .stepikSeparator }

    static var quizElementCorrectBorder: UIColor { UIColor.stepikGreen.withAlphaComponent(0.5) }

    static var quizElementWrongBorder: UIColor { UIColor.stepikLightRed.withAlphaComponent(0.5) }

    static var quizElementSelectedBorder: UIColor {
        .dynamic(
            light: UIColor.stepikVioletFixed.withAlphaComponent(0.5),
            dark: UIColor.stepikExtraLightVioletFixed.withAlphaComponent(0.5)
        )
    }
}

// MARK: - ColorPalette -

private enum ColorPalette {
    // MARK: - Accent Color -

    // MARK: Normal (grey06 #535366)

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let accent800 = UIColor(hex6: 0x353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let accent700 = UIColor(hex6: 0x535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let accent300 = UIColor(hex6: 0xD3D2E9)
    /// Color to use in dark mode and with a high contrast level.
    static let accent200 = UIColor(hex6: 0xE4E4FA)

    // MARK: Alpha 60

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 60.
    static let accent800Alpha60 = UIColor(hex8: 0x99353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 60.
    static let accent700Alpha60 = UIColor(hex8: 0x99535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 60.
    static let accent300Alpha60 = UIColor(hex8: 0x99D3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 60.
    static let accent200Alpha60 = UIColor(hex8: 0x99E4E4FA)

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

    // MARK: Alpha 18

    /// Color to use in light/unspecified mode and with a high contrast level, and with alpha component 18.
    static let accent800Alpha18 = UIColor(hex8: 0x2E353547)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level, and with alpha component 18.
    static let accent700Alpha18 = UIColor(hex8: 0x2E535366)
    /// Color to use in dark mode and with a normal/unspecified contrast level, and with alpha component 18.
    static let accent300Alpha18 = UIColor(hex8: 0x2ED3D2E9)
    /// Color to use in dark mode and with a high contrast level, and with alpha component 18.
    static let accent200Alpha18 = UIColor(hex8: 0x2EE4E4FA)

    // MARK: Dark (darkblue01 #282B41)

    static let darkAccent900 = UIColor(hex6: 0x282B41)

    // MARK: Extra Dark (darkblue02 #222437)

    static let extraDarkAccent900 = UIColor(hex6: 0x222437)

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

    // MARK: Light (red01)

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let lightRed400 = UIColor(hex6: 0xFF5945)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level (red01).
    static let lightRed300 = UIColor(hex6: 0xFF7965)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let lightRed200 = UIColor(hex6: 0xFFA190)
    /// Color to use in dark mode and with a high contrast level.
    static let lightRed100 = UIColor(hex6: 0xFFC6BB)

    // MARK: Extra Light (red02)

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let extraLightRed200 = UIColor(hex6: 0xFFB596)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level (red02).
    static let extraLightRed50 = UIColor(hex6: 0xFFEBE8)

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

    // MARK: Normal

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let yellow700 = UIColor(hex6: 0xFCC439)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let yellow600 = UIColor(hex6: 0xFEDB41)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let yellow300 = UIColor(hex6: 0xFDF17A)
    /// Color to use in dark mode and with a high contrast level.
    static let yellow200 = UIColor(hex6: 0xFEF5A0)

    // MARK: Light

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let lightYellow100 = UIColor(hex6: 0xFFE7BB)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let lightYellow50 = UIColor(hex6: 0xFFF6E5)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let lightYellow300 = UIColor(hex6: 0xFFC75C)
    /// Color to use in dark mode and with a high contrast level.
    static let lightYellow200 = UIColor(hex6: 0xFFD88C)

    // MARK: Dark

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let darkYellow500 = UIColor(hex6: 0xFE9B1B)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let darkYellow400 = UIColor(hex6: 0xFEA832)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let darkYellow300 = UIColor(hex6: 0xFEB954)
    /// Color to use in dark mode and with a high contrast level.
    static let darkYellow200 = UIColor(hex6: 0xFECD84)

    // MARK: - Grey -

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let grey200 = UIColor(hex6: 0xF0F0F0)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level (grey07).
    static let grey100 = UIColor(hex6: 0xF6F6F6)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let grey050 = UIColor(hex6: 0xFAFAFA)

    static let grey04 = UIColor(hex6: 0xEAECF0)
    static let grey08 = UIColor(hex6: 0xEAEAEA)

    // MARK: - Violet -

    static let violet01 = UIColor(hex6: 0x6C7BDF)
    static let violet02 = UIColor(hex6: 0xE9EBFA)
    static let violet03 = UIColor(hex6: 0x9CA6E6)
    static let violet04 = UIColor(hex6: 0x3E50CB)
    static let violet05 = UIColor(hex6: 0x98A0E8)

    // MARK: - Orange -

    /// Color to use in light/unspecified mode and with a high contrast level.
    static let orange900 = UIColor(hex6: 0xF7905C)
    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let orange800 = UIColor(hex6: 0xFFA961)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let orange500 = UIColor(hex6: 0xFFD370)
    /// Color to use in dark mode and with a high contrast level.
    static let orange400 = UIColor(hex6: 0xFFDA73)

    // MARK: - Gradient Courses -

    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let gradientCoursesBlue900 = UIColor(hex6: 0x00484E)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let gradientCoursesBlue200 = UIColor(hex6: 0x77CDDE)
    /// Color to use in dark mode and with a high contrast level.
    static let gradientCoursesBlue100 = UIColor(hex6: 0xACE1EB)

    /// Color to use in light/unspecified mode and with a normal/unspecified contrast level.
    static let gradientCoursesPink900 = UIColor(hex6: 0x18073D)
    /// Color to use in dark mode and with a normal/unspecified contrast level.
    static let gradientCoursesPink200 = UIColor(hex6: 0x9492B5)
    /// Color to use in dark mode and with a high contrast level.
    static let gradientCoursesPink100 = UIColor(hex6: 0xBEBDD3)
}
