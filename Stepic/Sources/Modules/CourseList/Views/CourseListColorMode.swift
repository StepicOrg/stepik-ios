import Foundation

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
                titleLabelColor: .stepikPrimaryText,
                showAllButtonColor: .stepikTertiaryText
            )
        case .dark:
            return .init(
                titleLabelColor: UIColor.white,
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
                imagesRenderingBackgroundColor: .stepikAccent,
                imagesRenderingTintColor: .stepikGreenFixed,
                itemTextColor: .stepikPrimaryText,
                itemImageTintColor: .stepikAccent
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

    var courseWidgetTitleLabelAppearance: CourseWidgetLabel.Appearance {
        var appearance = CourseWidgetLabel.Appearance(
            maxLinesCount: 3,
            font: .systemFont(ofSize: 16, weight: .medium)
        )

        switch self {
        case .light, .grouped:
            appearance.textColor = .stepikPrimaryText
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
            appearance.textColor = .stepikSecondaryText
        case .dark:
            appearance.textColor = UIColor.dynamic(
                light: UIColor.white.withAlphaComponent(0.6),
                dark: .stepikSecondaryText
            )
        }

        return appearance
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
