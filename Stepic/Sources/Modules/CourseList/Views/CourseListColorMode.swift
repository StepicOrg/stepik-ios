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
                titleLabelColor: UIColor(hex6: 0x535366),
                showAllButtonColor: UIColor(hex6: 0x535366, alpha: 0.3)
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
            appearance.backgroundColor = .white
            return appearance
        case .dark:
            var appearance = ExploreBlockContainerView.Appearance()
            appearance.backgroundColor = .stepikAccent
            return appearance
        }
    }

    var courseWidgetButtonAppearance: CourseWidgetButton.Appearance {
        switch self {
        case .light:
            return .init(
                textColor: UIColor.mainText,
                backgroundColor: UIColor(hex6: 0x535366, alpha: 0.06),
                callToActionTextColor: UIColor.stepikGreen,
                callToActionBackgroundColor: UIColor.stepikGreen.withAlphaComponent(0.1)
            )
        case .dark:
            return .init(
                textColor: UIColor.white,
                backgroundColor: UIColor(hex6: 0xffffff, alpha: 0.1),
                callToActionTextColor: UIColor.stepikGreen,
                callToActionBackgroundColor: UIColor.stepikGreen.withAlphaComponent(0.1)
            )
        }
    }

    var courseWidgetStatsViewAppearance: CourseWidgetStatsView.Appearance {
        switch self {
        case .light:
            return .init(
                imagesRenderingBackgroundColor: UIColor(hex6: 0x535366),
                imagesRenderingTintColor: UIColor(hex6: 0x89cc89),
                itemTextColor: UIColor.stepikAccent,
                itemImageTintColor: UIColor.stepikAccent
            )
        case .dark:
            return .init(
                imagesRenderingBackgroundColor: UIColor.white,
                imagesRenderingTintColor: UIColor(hex6: 0x89cc89),
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
