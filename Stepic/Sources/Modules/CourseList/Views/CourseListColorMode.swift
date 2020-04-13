import Foundation

enum CourseListColorMode {
    case light
    case dark

    static var `default`: CourseListColorMode { .light }
}

extension CourseListColorMode {
    var exploreBlockHeaderViewAppearance: ExploreBlockHeaderView.Appearance {
        switch self {
        case .light:
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
        switch self {
        case .light:
            var appearance = ExploreBlockContainerView.Appearance()
            appearance.backgroundColor = self.exploreBlockContainerViewBackgroundColor
            return appearance
        case .dark:
            var appearance = ExploreBlockContainerView.Appearance()
            appearance.backgroundColor = self.exploreBlockContainerViewBackgroundColor
            return appearance
        }
    }

    private var exploreBlockContainerViewBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                switch self {
                case .light:
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
            case .light:
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
        case .light:
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

    var courseWidgetLabelAppearance: CourseWidgetLabel.Appearance {
        switch self {
        case .light:
            var appearance = CourseWidgetLabel.Appearance()
            appearance.textColor = .stepikPrimaryText
            return appearance
        case .dark:
            var appearance = CourseWidgetLabel.Appearance()
            appearance.textColor = .white
            return appearance
        }
    }

    var courseWidgetSummaryLabelAppearance: CourseWidgetLabel.Appearance {
        var appearance = CourseWidgetLabel.Appearance(
            maxLinesCount: 0,
            font: .systemFont(ofSize: 12, weight: .regular)
        )

        switch self {
        case .light:
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
        case .light:
            return .dynamic(light: .stepikGrey8Fixed, dark: .stepikSeparator)
        case .dark:
            return .stepikSeparator
        }
    }
}
