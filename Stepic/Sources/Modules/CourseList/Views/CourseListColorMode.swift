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
                titleLabelColor: UIColor.stepikAccent,
                showAllButtonColor: UIColor.stepikAccentAlpha30
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

    var courseWidgetButtonAppearance: CourseWidgetButton.Appearance {
        switch self {
        case .light:
            return .init(
                textColor: UIColor.stepikPrimaryText,
                backgroundColor: self.courseWidgetButtonBackgroundColor,
                callToActionTextColor: UIColor.stepikGreen,
                callToActionBackgroundColor: UIColor.stepikGreen.withAlphaComponent(0.1)
            )
        case .dark:
            return .init(
                textColor: UIColor.white,
                backgroundColor: self.courseWidgetButtonBackgroundColor,
                callToActionTextColor: UIColor.stepikGreen,
                callToActionBackgroundColor: UIColor.stepikGreen.withAlphaComponent(0.1)
            )
        }
    }

    private var courseWidgetButtonBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                switch self {
                case .light:
                    if traitCollection.userInterfaceStyle == .dark {
                        return .stepikSecondaryBackground
                    }
                    return .stepikAccentAlpha06
                case .dark:
                    return UIColor.white.withAlphaComponent(0.1)
                }
            }
        } else {
            switch self {
            case .light:
                return .stepikAccentAlpha06
            case .dark:
                return UIColor.white.withAlphaComponent(0.1)
            }
        }
    }

    var courseWidgetStatsViewAppearance: CourseWidgetStatsView.Appearance {
        switch self {
        case .light:
            return .init(
                imagesRenderingBackgroundColor: UIColor.stepikAccent,
                imagesRenderingTintColor: UIColor.stepikGreen,
                itemTextColor: UIColor.stepikAccent,
                itemImageTintColor: UIColor.stepikAccent
            )
        case .dark:
            return .init(
                imagesRenderingBackgroundColor: UIColor.white,
                imagesRenderingTintColor: UIColor.stepikGreen,
                itemTextColor: UIColor.white,
                itemImageTintColor: UIColor.white
            )
        }
    }

    var courseWidgetLabelAppearance: CourseWidgetLabel.Appearance {
        switch self {
        case .light:
            var appearance = CourseWidgetLabel.Appearance()
            appearance.textColor = .stepikAccent
            return appearance
        case .dark:
            var appearance = CourseWidgetLabel.Appearance()
            appearance.textColor = .white
            return appearance
        }
    }
}
