import Foundation

enum CourseListColorMode {
    case light
    case dark
    case grouped
    case clearLight

    static var `default`: CourseListColorMode { .light }
}

extension CourseListColorMode {
    var exploreBlockHeaderViewAppearance: ExploreBlockHeaderView.Appearance {
        switch self {
        case .light, .grouped, .clearLight:
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
        appearance.background = .color(self.exploreBlockContainerViewBackgroundColor)
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
                case .clearLight:
                    return .clear
                }
            }
        } else {
            switch self {
            case .light, .grouped:
                return .white
            case .dark:
                return .stepikAccentFixed
            case .clearLight:
                return .clear
            }
        }
    }

    var courseWidgetContinueLearningButtonAppearance: CourseWidgetContinueLearningButton.Appearance {
        .init(iconTintColor: .stepikGreen, textColor: .stepikGreen)
    }

    var courseWidgetStatsViewAppearance: CourseWidgetStatsView.Appearance {
        switch self {
        case .light, .grouped, .clearLight:
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

    var courseWidgetTitleLabelAppearance: CourseWidgetLabel.Appearance {
        var appearance = CourseWidgetLabel.Appearance(
            maxLinesCount: 3,
            font: .systemFont(ofSize: 16, weight: .medium)
        )

        switch self {
        case .light, .grouped, .clearLight:
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
        case .light, .grouped, .clearLight:
            appearance.textColor = .stepikSystemSecondaryText
        case .dark:
            appearance.textColor = UIColor.dynamic(
                light: UIColor.white.withAlphaComponent(0.6),
                dark: .stepikSystemSecondaryText
            )
        }

        return appearance
    }

    var courseWidgetBorderColor: UIColor {
        switch self {
        case .light, .grouped, .clearLight:
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
        case .light, .clearLight:
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
