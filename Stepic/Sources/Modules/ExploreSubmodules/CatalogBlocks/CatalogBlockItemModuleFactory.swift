import UIKit

enum CatalogBlockItemModuleFactory {
    typealias Module = (viewController: UIViewController, containerView: UIView)

    static func makeCatalogBlockModule(block: CatalogBlock, interactor: CatalogBlocksInteractorProtocol) -> Module? {
        guard let kind = block.kind else {
            return nil
        }

        switch kind {
        case .fullCourseLists:
            guard let contentItem = block.content.first as? FullCourseListsCatalogBlockContentItem else {
                return nil
            }

            let type = CatalogBlockCourseListType(
                courseListID: contentItem.id,
                coursesIDs: contentItem.courses
            )

            let assembly = HorizontalCourseListAssembly(
                type: type,
                colorMode: .light,
                courseViewSource: .catalogBlock(id: block.id),
                output: interactor as? CourseListOutputProtocol
            )
            let viewController = assembly.makeModule()
            assembly.moduleInput?.setOnlineStatus()

            let containerView = CourseListContainerViewFactory()
                .makeHorizontalCatalogBlocksContainerView(
                    for: viewController.view,
                    headerDescription: .init(
                        title: block.title,
                        subtitle: FormatterHelper.catalogBlockCoursesCount(contentItem.coursesCount),
                        description: block.descriptionString,
                        isTitleVisible: block.isTitleVisible,
                        shouldShowAllButton: true
                    ),
                    contentViewInsets: .zero
                )
            containerView.onShowAllButtonClick = { [weak interactor] in
                interactor?.doFullCourseListPresentation(
                    request: .init(
                        courseListType: type,
                        presentationDescription: .init(title: block.title)
                    )
                )
            }

            return (viewController: viewController, containerView: containerView)
        case .recommendedCourses:
            let type = RecommendationsCourseListType(
                id: block.id,
                language: ContentLanguage(languageString: block.language),
                platform: block.platformType ?? .ios
            )

            let assembly = HorizontalCourseListAssembly(
                type: type,
                colorMode: .light,
                courseViewSource: .recommendation,
                output: interactor as? CourseListOutputProtocol
            )
            let viewController = assembly.makeModule()
            assembly.moduleInput?.setOnlineStatus()

            let containerView = CourseListContainerViewFactory()
                .makeHorizontalCatalogBlocksContainerView(
                    for: viewController.view,
                    headerDescription: .init(
                        title: block.title,
                        subtitle: nil,
                        description: block.descriptionString,
                        isTitleVisible: block.isTitleVisible,
                        shouldShowAllButton: true
                    ),
                    contentViewInsets: .zero
                )
            containerView.onShowAllButtonClick = { [weak interactor] in
                interactor?.doFullCourseListPresentation(
                    request: .init(
                        courseListType: type,
                        presentationDescription: .init(title: block.title)
                    )
                )
            }

            return (viewController: viewController, containerView: containerView)
        case .simpleCourseLists:
            guard let blockAppearance = block.appearance else {
                return nil
            }

            let assembly = SimpleCourseListAssembly(
                catalogBlockID: block.id,
                layoutType: .init(catalogBlockAppearance: blockAppearance),
                output: interactor as? SimpleCourseListOutputProtocol
            )
            let viewController = assembly.makeModule()

            var contentViewInsets = CourseListContainerViewFactory.Appearance
                .horizontalCatalogBlocksContentInsets
            if !block.isTitleVisible {
                contentViewInsets.top = 0
            }

            let containerView = CourseListContainerViewFactory()
                .makeHorizontalCatalogBlocksContainerView(
                    for: viewController.view,
                    headerDescription: .init(
                        title: block.title,
                        subtitle: nil,
                        description: block.descriptionString,
                        isTitleVisible: block.isTitleVisible,
                        shouldShowAllButton: false
                    ),
                    contentViewInsets: contentViewInsets
                )

            return (viewController: viewController, containerView: containerView)
        case .authors:
            let assembly = AuthorsCourseListAssembly(
                catalogBlockID: block.id,
                output: interactor as? AuthorsCourseListOutputProtocol
            )
            let viewController = assembly.makeModule()

            let containerView = CourseListContainerViewFactory()
                .makeHorizontalCatalogBlocksContainerView(
                    for: viewController.view,
                    headerDescription: .init(
                        title: block.title,
                        subtitle: FormatterHelper.authorsCount(block.content.count),
                        description: block.descriptionString,
                        isTitleVisible: block.isTitleVisible,
                        shouldShowAllButton: false
                    ),
                    contentViewInsets: .zero
                )

            return (viewController: viewController, containerView: containerView)
        case .specializations:
            guard block.appearance == .specializationsStepikAcademy else {
                return nil
            }

            return nil
        }
    }
}
