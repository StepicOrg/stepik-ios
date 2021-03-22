import UIKit

protocol CatalogBlocksViewControllerProtocol: AnyObject {
    func displayCatalogBlocks(viewModel: CatalogBlocks.CatalogBlocksLoad.ViewModel)
}

final class CatalogBlocksViewController: UIViewController, ControllerWithStepikPlaceholder {
    var placeholderContainer = StepikPlaceholderControllerContainer()

    private let interactor: CatalogBlocksInteractorProtocol
    private var state: CatalogBlocks.ViewControllerState

    private var catalogBlocksView: CatalogBlocksView? { self.view as? CatalogBlocksView }

    init(
        interactor: CatalogBlocksInteractorProtocol,
        initialState: CatalogBlocks.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CatalogBlocksView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholders()
        self.updateState(newState: self.state)

        self.interactor.doCatalogBlocksLoad(request: .init())
    }

    private func updateState(newState: CatalogBlocks.ViewControllerState) {
        self.state = newState

        switch self.state {
        case .loading:
            self.catalogBlocksView?.showLoading()
            self.isPlaceholderShown = false
        case .error:
            self.catalogBlocksView?.hideLoading()
            self.showPlaceholder(for: .connectionError)
        case .result(let data):
            self.catalogBlocksView?.hideLoading()
            self.isPlaceholderShown = false

            for block in data {
                guard let kind = block.kind else {
                    continue
                }

                switch kind {
                case .fullCourseLists:
                    guard let contentItem = block.content.first as? FullCourseListsCatalogBlockContentItem else {
                        continue
                    }

                    let type = CatalogBlockCourseListType(
                        courseListID: contentItem.id,
                        coursesIDs: contentItem.courses
                    )

                    let assembly = HorizontalCourseListAssembly(
                        type: type,
                        colorMode: .light,
                        courseViewSource: .catalogBlock(id: block.id),
                        output: self.interactor as? CourseListOutputProtocol
                    )
                    let viewController = assembly.makeModule()
                    assembly.moduleInput?.setOnlineStatus()
                    self.addChild(viewController)

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
                    containerView.onShowAllButtonClick = { [weak self] in
                        self?.interactor.doFullCourseListPresentation(
                            request: .init(
                                courseListType: type,
                                presentationDescription: .init(title: block.title)
                            )
                        )
                    }
                    self.catalogBlocksView?.addBlockView(containerView)
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
                        output: self.interactor as? CourseListOutputProtocol
                    )
                    let viewController = assembly.makeModule()
                    assembly.moduleInput?.setOnlineStatus()
                    self.addChild(viewController)

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
                    containerView.onShowAllButtonClick = { [weak self] in
                        self?.interactor.doFullCourseListPresentation(
                            request: .init(
                                courseListType: type,
                                presentationDescription: .init(title: block.title)
                            )
                        )
                    }
                    self.catalogBlocksView?.addBlockView(containerView)
                case .simpleCourseLists:
                    guard let blockAppearance = block.appearance else {
                        continue
                    }

                    let assembly = SimpleCourseListAssembly(
                        catalogBlockID: block.id,
                        layoutType: .init(catalogBlockAppearance: blockAppearance),
                        output: self.interactor as? SimpleCourseListOutputProtocol
                    )
                    let viewController = assembly.makeModule()
                    self.addChild(viewController)

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
                    self.catalogBlocksView?.addBlockView(containerView)
                case .authors:
                    let assembly = AuthorsCourseListAssembly(
                        catalogBlockID: block.id,
                        output: self.interactor as? AuthorsCourseListOutputProtocol
                    )
                    let viewController = assembly.makeModule()
                    self.addChild(viewController)

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
                    self.catalogBlocksView?.addBlockView(containerView)
                }
            }
        }
    }

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .refreshCatalogBlocks,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    strongSelf.interactor.doCatalogBlocksLoad(request: .init())
                }
            ),
            for: .connectionError
        )
    }
}

// MARK: - CatalogBlocksViewController: CatalogBlocksViewControllerProtocol -

extension CatalogBlocksViewController: CatalogBlocksViewControllerProtocol {
    func displayCatalogBlocks(viewModel: CatalogBlocks.CatalogBlocksLoad.ViewModel) {
        self.children.forEach { $0.removeFromParent() }
        self.catalogBlocksView?.removeAllBlocks()
        self.updateState(newState: viewModel.state)
    }
}
