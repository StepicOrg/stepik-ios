import UIKit

enum CourseListColorMode {
    case light
    case dark
    case grouped

    static var `default`: CourseListColorMode { .light }
}

extension CourseListColorMode {
    var exploreBlockHeaderViewAppearance: ExploreBlockHeaderView.Appearance {
        switch self {
        case .light, .grouped:
            return .init(
                titleLabelColor: .stepikSystemPrimaryText,
                showAllButtonColor: .stepikSystemSecondaryText
            )
        case .dark:
            return .init(
                titleLabelColor: .white,
                showAllButtonColor: UIColor.white.withAlphaComponent(0.3)
            )
        }
    }

    var exploreBlockContainerViewAppearance: ExploreBlockContainerView.Appearance {
        var appearance = ExploreBlockContainerView.Appearance()
        appearance.backgroundColor = self.exploreBlockContainerViewBackgroundColor
        return appearance
    }

    var exploreCatalogBlockContainerViewAppearance: ExploreCatalogBlockContainerView.Appearance {
        var appearance = ExploreCatalogBlockContainerView.Appearance()
        appearance.backgroundColor = self.exploreBlockContainerViewBackgroundColor
        return appearance
    }

    var exploreStepikAcademyBlockContainerViewAppearance: ExploreStepikAcademyBlockContainerView.Appearance {
        var appearance = ExploreStepikAcademyBlockContainerView.Appearance()
        appearance.backgroundColor = self.exploreBlockContainerViewBackgroundColor
        return appearance
    }

    private var exploreBlockContainerViewBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                switch self {
                case .light, .grouped:
                    return .stepikBackground
                case .dark:
                    if traitCollection.userInterfaceStyle == .dark {
                        return .stepikSecondaryBackground
                    }
                    return .stepikAccentFixed
                }
            }
        } else {
            switch self {
            case .light, .grouped:
                return .white
            case .dark:
                return .stepikAccentFixed
            }
        }
    }

    var courseWidgetContinueLearningButtonAppearance: CourseWidgetContinueLearningButton.Appearance {
        .init(iconTintColor: .stepikGreen, textColor: .stepikGreen)
    }

    var courseWidgetStatsViewAppearance: CourseWidgetStatsView.Appearance {
        switch self {
        case .light, .grouped:
            return .init(
                imagesRenderingBackgroundColor: .stepikSystemSecondaryText,
                imagesRenderingTintColor: .stepikGreenFixed,
                itemTextColor: .stepikSystemSecondaryText,
                itemImageTintColor: .stepikSystemSecondaryText
            )
        case .dark:
            return .init(
                imagesRenderingBackgroundColor: .white,
                imagesRenderingTintColor: .stepikGreenFixed,
                itemTextColor: .white,
                itemImageTintColor: .white
            )
        }
    }

    var courseWidgetProgressViewAppearance: CourseWidgetProgressView.Appearance {
        let progressTextLabelTextColor = UIColor.stepikMaterialSecondaryText
        let progressBarTrackTintColor = UIColor.onSurface.withAlphaComponent(0.12)

        var appearance = CourseWidgetProgressView.Appearance(
            progressTextLabelAppearance: .init(
                maxLinesCount: 1,
                font: .systemFont(ofSize: 12, weight: .regular),
                textColor: progressTextLabelTextColor
            ),
            progressBarTrackTintColor: progressBarTrackTintColor
        )

        switch self {
        case .light, .grouped:
            return appearance
        case .dark:
            appearance.progressTextLabelAppearance.textColor = .dynamic(
                light: .white.withAlphaComponent(0.6),
                dark: progressTextLabelTextColor
            )
            appearance.progressBarTrackTintColor = .dynamic(
                light: .white.withAlphaComponent(0.12),
                dark: progressBarTrackTintColor
            )
            return appearance
        }
    }

    var courseWidgetTitleLabelAppearance: CourseWidgetLabel.Appearance {
        var appearance = CourseWidgetLabel.Appearance(
            maxLinesCount: 3,
            font: .systemFont(ofSize: 16, weight: .medium)
        )

        switch self {
        case .light, .grouped:
            appearance.textColor = .stepikSystemPrimaryText
        case .dark:
            appearance.textColor = .white
        }

        return appearance
    }

    var courseWidgetSummaryLabelAppearance: CourseWidgetLabel.Appearance {
        var appearance = CourseWidgetLabel.Appearance(
            maxLinesCount: 0,
            font: .systemFont(ofSize: 14, weight: .regular)
        )

        switch self {
        case .light, .grouped:
            appearance.textColor = .stepikSystemSecondaryText
        case .dark:
            appearance.textColor = UIColor.dynamic(
                light: UIColor.white.withAlphaComponent(0.6),
                dark: .stepikSystemSecondaryText
            )
        }

        return appearance
    }

    var courseWidgetBadgeTintColor: UIColor {
        switch self {
        case .light, .grouped:
            return .stepikSystemSecondaryText
        case .dark:
            return .dynamic(
                light: .white.withAlphaComponent(0.6),
                dark: .stepikSystemSecondaryText
            )
        }
    }

    var courseWidgetBorderColor: UIColor {
        switch self {
        case .light, .grouped:
            return .dynamic(light: .stepikGrey8Fixed, dark: .stepikSeparator)
        case .dark:
            if #available(iOS 13.0, *) {
                return .stepikSeparator
            } else {
                return UIColor.stepikOpaqueSeparator.withAlphaComponent(0.6)
            }
        }
    }

    var courseWidgetBackgroundColor: UIColor {
        switch self {
        case .light:
            return .dynamic(light: .white, dark: .stepikSecondaryBackground)
        case .grouped:
            return .stepikSecondaryGroupedBackground
        case .dark:
            let lightUserInterfaceStyleColor = UIColor(hex6: 0x49495C)

            if #available(iOS 13.0, *) {
                return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return .stepikTertiaryBackground
                    }
                    return lightUserInterfaceStyleColor
                }
            } else {
                return lightUserInterfaceStyleColor
            }
        }
    }
}
