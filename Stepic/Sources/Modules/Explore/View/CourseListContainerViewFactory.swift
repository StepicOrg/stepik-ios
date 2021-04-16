import UIKit

final class CourseListContainerViewFactory {
    struct HorizontalHeaderDescription {
        var title: String?
        var summary: String?
        var shouldShowAllButton: Bool

        init(
            title: String?,
            summary: String?,
            shouldShowAllButton: Bool = true
        ) {
            self.title = title
            self.summary = summary
            self.shouldShowAllButton = shouldShowAllButton
        }
    }

    struct HorizontalCoursesCollectionHeaderDescription {
        var title: String?
        var summary: String?
        var description: String
        var color: GradientCoursesPlaceholderView.Color
    }

    struct HorizontalCatalogBlocksHeaderDescription {
        var title: String?
        var subtitle: String?
        var description: String?
        var isTitleVisible: Bool
        var shouldShowAllButton: Bool

        init(
            title: String?,
            subtitle: String?,
            description: String?,
            isTitleVisible: Bool = true,
            shouldShowAllButton: Bool = true
        ) {
            self.title = title
            self.subtitle = subtitle
            self.description = description
            self.isTitleVisible = isTitleVisible
            self.shouldShowAllButton = shouldShowAllButton
        }
    }

    struct HorizontalStepikAcademyHeaderDescription {
        var title: String
        var summary: String

        init(
            title: String = NSLocalizedString("StepikAcademyCourseListHeaderTitle", comment: ""),
            summary: String = NSLocalizedString("StepikAcademyCourseListHeaderDescription", comment: "")
        ) {
            self.title = title
            self.summary = summary
        }
    }

    enum Appearance {
        static let horizontalContentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        static let horizontalCoursesCollectionContentInsets = UIEdgeInsets(
            top: 0,
            left: -1,
            bottom: 8, // cause have top spacing in next
            right: -1
        )
        static let horizontalCatalogBlocksContentInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }

    let colorMode: CourseListColorMode

    init(colorMode: CourseListColorMode = .default) {
        self.colorMode = colorMode
    }

    // MARK: Public API

    func makeHorizontalContainerView(
        for contentView: UIView,
        headerDescription: HorizontalHeaderDescription,
        headerViewInsets: UIEdgeInsets? = nil,
        contentViewInsets: UIEdgeInsets? = Appearance.horizontalContentInsets
    ) -> ExploreBlockContainerView {
        let headerView = ExploreBlockHeaderView(
            appearance: self.colorMode.exploreBlockHeaderViewAppearance
        )
        headerView.shouldShowAllButton = headerDescription.shouldShowAllButton
        headerView.titleText = headerDescription.title
        headerView.summaryText = headerDescription.summary

        return self.makeHorizontalContainerView(
            headerView: headerView,
            contentView: contentView,
            headerViewInsets: headerViewInsets,
            contentViewInsets: contentViewInsets
        )
    }

    func makeHorizontalCoursesCollectionContainerView(
        for contentView: UIView,
        headerDescription: HorizontalCoursesCollectionHeaderDescription,
        headerViewInsets: UIEdgeInsets? = nil,
        contentViewInsets: UIEdgeInsets? = Appearance.horizontalContentInsets
    ) -> ExploreBlockContainerView {
        let headerView = ExploreCoursesCollectionHeaderView(
            description: headerDescription.description,
            color: headerDescription.color
        )
        headerView.titleText = headerDescription.title
        headerView.summaryText = headerDescription.summary

        return self.makeHorizontalContainerView(
            headerView: headerView,
            contentView: contentView,
            headerViewInsets: headerViewInsets,
            contentViewInsets: contentViewInsets
        )
    }

    func makeHorizontalCatalogBlocksContainerView(
        for contentView: UIView,
        headerDescription: HorizontalCatalogBlocksHeaderDescription,
        contentViewInsets: UIEdgeInsets? = Appearance.horizontalCatalogBlocksContentInsets
    ) -> ExploreCatalogBlockContainerView {
        let headerView = headerDescription.isTitleVisible ? ExploreCatalogBlockHeaderView() : nil
        headerView?.titleText = headerDescription.title
        headerView?.summaryText = headerDescription.subtitle
        headerView?.descriptionText = headerDescription.description
        headerView?.shouldShowAllButton = headerDescription.shouldShowAllButton

        return self.makeHorizontalCatalogBlockContainerView(
            headerView: headerView,
            contentView: contentView,
            contentViewInsets: contentViewInsets
        )
    }

    func makeHorizontalStepikAcademyBlockContainerView(
        for contentView: UIView,
        headerDescription: HorizontalStepikAcademyHeaderDescription = HorizontalStepikAcademyHeaderDescription()
    ) -> ExploreStepikAcademyBlockContainerView {
        let headerView = ExploreStepikAcademyBlockHeaderView()
        headerView.titleText = headerDescription.title
        headerView.summaryText = headerDescription.summary

        return self.makeHorizontalStepikAcademyBlockContainerView(
            headerView: headerView,
            contentView: contentView
        )
    }

    // MARK: Private API

    private func makeHorizontalContainerView(
        headerView: UIView & ExploreBlockHeaderViewProtocol,
        contentView: UIView,
        headerViewInsets: UIEdgeInsets?,
        contentViewInsets: UIEdgeInsets?
    ) -> ExploreBlockContainerView {
        var appearance = self.colorMode.exploreBlockContainerViewAppearance

        if let headerViewInsets = headerViewInsets {
            appearance.headerViewInsets = headerViewInsets
        }

        if let contentViewInsets = contentViewInsets {
            appearance.contentViewInsets = contentViewInsets
        }

        return ExploreBlockContainerView(
            headerView: headerView,
            contentView: contentView,
            shouldShowSeparator: false,
            appearance: appearance
        )
    }

    private func makeHorizontalCatalogBlockContainerView(
        headerView: (UIView & ExploreCatalogBlockHeaderViewProtocol)?,
        contentView: UIView,
        contentViewInsets: UIEdgeInsets?
    ) -> ExploreCatalogBlockContainerView {
        var appearance = self.colorMode.exploreCatalogBlockContainerViewAppearance

        if let contentViewInsets = contentViewInsets {
            appearance.contentViewInsets = contentViewInsets
        }

        return ExploreCatalogBlockContainerView(
            headerView: headerView,
            contentView: contentView,
            appearance: appearance
        )
    }

    private func makeHorizontalStepikAcademyBlockContainerView(
        headerView: UIView & ExploreBlockHeaderViewProtocol,
        contentView: UIView
    ) -> ExploreStepikAcademyBlockContainerView {
        ExploreStepikAcademyBlockContainerView(
            headerView: headerView,
            contentView: contentView,
            appearance: self.colorMode.exploreStepikAcademyBlockContainerViewAppearance
        )
    }
}
