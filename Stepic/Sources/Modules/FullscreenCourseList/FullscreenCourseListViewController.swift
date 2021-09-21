import UIKit

protocol FullscreenCourseListViewControllerProtocol: AnyObject {
    func displayCourseInfo(viewModel: FullscreenCourseList.CourseInfoPresentation.ViewModel)
    func displayCourseSyllabus(viewModel: FullscreenCourseList.CourseSyllabusPresentation.ViewModel)
    func displayLastStep(viewModel: FullscreenCourseList.LastStepPresentation.ViewModel)
    func displayAuthorization(viewModel: FullscreenCourseList.PresentAuthorization.ViewModel)
    func displayPlaceholder(viewModel: FullscreenCourseList.PresentPlaceholder.ViewModel)
    func displayHidePlaceholder(viewModel: FullscreenCourseList.HidePlaceholder.ViewModel)
    func displayPaidCourseBuying(viewModel: FullscreenCourseList.PaidCourseBuyingPresentation.ViewModel)
    func displaySimilarAuthors(viewModel: FullscreenCourseList.SimilarAuthorsPresentation.ViewModel)
    func displaySimilarCourseLists(viewModel: FullscreenCourseList.SimilarCourseListsPresentation.ViewModel)
    func displayProfile(viewModel: FullscreenCourseList.ProfilePresentation.ViewModel)
    func displayFullscreenCourseList(viewModel: FullscreenCourseList.FullscreenCourseListModulePresentation.ViewModel)
}

extension FullscreenCourseListViewController {
    enum Appearance {
        static var transparentNavigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState {
            .init(shadowViewAlpha: 0, backgroundColor: .clear)
        }
    }
}

final class FullscreenCourseListViewController: UIViewController, ControllerWithStepikPlaceholder {
    let interactor: FullscreenCourseListInteractorProtocol
    private let courseListType: CourseListType
    private let presentationDescription: CourseList.PresentationDescription?
    private let courseViewSource: AnalyticsEvent.CourseViewSource

    lazy var fullscreenCourseListView = self.view as? FullscreenCourseListView

    private var submodules: [Submodule] = []
    private var currentFilters = [CourseListFilter.Filter]()

    private lazy var courseListFilterBarButtonItem = CourseListFilterBarButtonItem(
        target: self,
        action: #selector(self.courseListFilterBarButtonItemClicked)
    )

    var placeholderContainer = StepikPlaceholderControllerContainer()

    init(
        interactor: FullscreenCourseListInteractorProtocol,
        courseListType: CourseListType,
        presentationDescription: CourseList.PresentationDescription?,
        courseViewSource: AnalyticsEvent.CourseViewSource
    ) {
        self.interactor = interactor
        self.presentationDescription = presentationDescription
        self.courseListType = courseListType
        self.courseViewSource = courseViewSource

        super.init(nibName: nil, bundle: nil)

        if !(self.presentationDescription?.title?.isEmpty ?? true) {
            self.title = self.presentationDescription?.title
        } else if self.presentationDescription?.headerViewDescription != nil {
            self.title = nil
        } else {
            self.title = NSLocalizedString("AllCourses", comment: "")
        }

        if self.presentationDescription?.courseListFilterDescription != nil {
            self.navigationItem.rightBarButtonItem = self.courseListFilterBarButtonItem
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = FullscreenCourseListView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholders()
        self.refreshCourseListState()

        self.makeNavigationBarTransparentIfHasGradientHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.makeNavigationBarTransparentIfHasGradientHeader()
    }

    // MARK: - Private API

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    self?.refreshCourseListState()
                }
            ),
            for: .connectionError
        )

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .emptySearch,
                action: { [weak self] in
                    self?.refreshCourseListState()
                }
            ),
            for: .empty
        )
    }

    private func makeNavigationBarTransparentIfHasGradientHeader() {
        guard self.presentationDescription?.headerViewDescription != nil else {
            return
        }

        self.styledNavigationController?.removeBackButtonTitleForTopController()

        self.styledNavigationController?.changeBackgroundColor(
            Appearance.transparentNavigationBarAppearance.backgroundColor,
            sender: self
        )
        self.styledNavigationController?.changeShadowViewAlpha(
            Appearance.transparentNavigationBarAppearance.shadowViewAlpha,
            sender: self
        )

        self.styledNavigationController?.setNeedsNavigationBarAppearanceUpdate(sender: self)
    }

    @objc
    private func courseListFilterBarButtonItemClicked() {
        guard let presentationDescription = self.presentationDescription?.courseListFilterDescription else {
            return
        }

        let assembly = CourseListFilterAssembly(
            presentationDescription: .init(
                availableFilters: presentationDescription.availableFilters,
                prefilledFilters: self.currentFilters,
                defaultCourseLanguage: presentationDescription.defaultCourseLanguage
            ),
            output: self
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, embedInNavigation: false, modalPresentationStyle: .stepikAutomatic)
    }

    // MARK: CourseList

    private func refreshCourseListState() {
        if let submodule = self.getSubmodule(type: .courseList) {
            self.removeSubmodule(submodule)
        }

        var resultPresentationDescription = self.presentationDescription
        resultPresentationDescription?.headerViewDescription?.shouldExtendEdgesUnderTopBar = false

        let courseListAssembly = VerticalCourseListAssembly(
            type: self.courseListType,
            colorMode: .light,
            courseViewSource: self.courseViewSource,
            presentationDescription: resultPresentationDescription,
            output: self.interactor
        )
        let courseListViewController = courseListAssembly.makeModule()

        self.registerSubmodule(
            .init(
                viewController: courseListViewController,
                view: courseListViewController.view,
                type: .courseList,
                moduleInput: courseListAssembly.moduleInput
            )
        )

        if let moduleInput = courseListAssembly.moduleInput {
            self.interactor.doOnlineModeReset(request: .init(module: moduleInput))
        }

        self.currentFilters = resultPresentationDescription?.courseListFilterDescription?.prefilledFilters ?? []
    }

    // MARK: SimilarAuthorsCourseList

    private enum SimilarAuthorsCourseListState {
        case visible(ids: [User.IdType])
        case hidden
    }

    private func refreshSimilarAuthorsCourseListState(_ state: SimilarAuthorsCourseListState) {
        switch state {
        case .visible(let ids):
            guard self.getSubmodule(type: .similarAuthors) == nil else {
                return
            }

            let authorsCourseListAssembly = AuthorsCourseListAssembly(
                authors: ids,
                output: self.interactor as? AuthorsCourseListOutputProtocol
            )
            let authorsViewController = authorsCourseListAssembly.makeModule()

            let containerView = CourseListContainerViewFactory()
                .makeHorizontalCatalogBlocksContainerView(
                    for: authorsViewController.view,
                    headerDescription: .init(
                        title: NSLocalizedString("SimilarCourseListAuthorsHeaderTitle", comment: ""),
                        subtitle: nil,
                        description: nil,
                        isTitleVisible: true,
                        shouldShowAllButton: false
                    ),
                    contentViewInsets: .zero
                )

            self.registerSubmodule(
                .init(
                    viewController: authorsViewController,
                    view: containerView,
                    type: .similarAuthors
                )
            )
        case .hidden:
            if let submodule = self.getSubmodule(type: .similarAuthors) {
                self.removeSubmodule(submodule)
            }
        }
    }

    // MARK: SimilarCourseLists

    private enum SimilarCourseListsState {
        case visible(ids: [CourseListModel.IdType])
        case hidden
    }

    private func refreshSimilarCourseListsState(_ state: SimilarCourseListsState) {
        switch state {
        case .visible(let ids):
            guard self.getSubmodule(type: .similarCourseLists) == nil else {
                return
            }

            let simpleCourseListAssembly = SimpleCourseListAssembly(
                courseLists: ids,
                layoutType: .default,
                output: self.interactor as? SimpleCourseListOutputProtocol
            )
            let simpleCourseListViewController = simpleCourseListAssembly.makeModule()

            let containerView = CourseListContainerViewFactory()
                .makeHorizontalCatalogBlocksContainerView(
                    for: simpleCourseListViewController.view,
                    headerDescription: .init(
                        title: NSLocalizedString("SimilarCourseListHeaderTitle", comment: ""),
                        subtitle: nil,
                        description: nil,
                        isTitleVisible: true,
                        shouldShowAllButton: false
                    )
                )

            self.registerSubmodule(
                .init(
                    viewController: simpleCourseListViewController,
                    view: containerView,
                    type: .similarCourseLists
                )
            )
        case .hidden:
            if let submodule = self.getSubmodule(type: .similarCourseLists) {
                self.removeSubmodule(submodule)
            }
        }
    }

    // MARK: Manage Submodules

    private func registerSubmodule(_ submodule: Submodule) {
        self.submodules.append(submodule)

        if let viewController = submodule.viewController {
            self.addChild(viewController)
        }

        guard let insertingSubmoduleView = submodule.view else {
            return print("FullscreenCourseListViewController :: failed insert submodule view")
        }

        // Subviews has same position as in corresponding Submodule object
        for module in self.submodules where module.type.position >= submodule.type.position {
            if let nextSubmoduleView = module.view {
                self.fullscreenCourseListView?.insertBlockView(insertingSubmoduleView, before: nextSubmoduleView)
            }
            return
        }
    }

    private func removeSubmodule(_ submodule: Submodule) {
        if let submoduleView = submodule.view {
            self.fullscreenCourseListView?.removeBlockView(submoduleView)
        }
        submodule.viewController?.removeFromParent()
        self.submodules = self.submodules.filter { submodule.view != $0.view }
    }

    private func getSubmodule(type: Submodule.SubmoduleType) -> Submodule? {
        self.submodules.first(where: { $0.type == type })
    }

    // MARK: - Inner Types

    private final class Submodule {
        weak var viewController: UIViewController?
        weak var view: UIView?

        let type: SubmoduleType
        private let moduleInput: AnyObject?

        var courseListModuleInput: CourseListInputProtocol? {
            self.moduleInput as? CourseListInputProtocol
        }

        init(viewController: UIViewController?, view: UIView?, type: SubmoduleType, moduleInput: AnyObject? = nil) {
            self.viewController = viewController
            self.view = view
            self.type = type
            self.moduleInput = moduleInput
        }

        enum SubmoduleType: CaseIterable {
            case courseList
            case similarAuthors
            case similarCourseLists

            var position: Int {
                for (index, type) in Self.allCases.enumerated() where self == type {
                    return index
                }
                fatalError("Invalid type")
            }
        }
    }
}

// MARK: - FullscreenCourseListViewController: FullscreenCourseListViewControllerProtocol -

extension FullscreenCourseListViewController: FullscreenCourseListViewControllerProtocol {
    func displayPlaceholder(viewModel: FullscreenCourseList.PresentPlaceholder.ViewModel) {
        switch viewModel.state {
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .empty:
            self.showPlaceholder(for: .empty)
        }
    }

    func displayHidePlaceholder(viewModel: FullscreenCourseList.HidePlaceholder.ViewModel) {
        self.isPlaceholderShown = false
    }

    func displayCourseInfo(viewModel: FullscreenCourseList.CourseInfoPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(
            courseID: viewModel.courseID,
            initialTab: .info,
            courseViewSource: viewModel.courseViewSource
        )
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseSyllabus(viewModel: FullscreenCourseList.CourseSyllabusPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(
            courseID: viewModel.courseID,
            initialTab: .syllabus,
            courseViewSource: viewModel.courseViewSource
        )
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayLastStep(viewModel: FullscreenCourseList.LastStepPresentation.ViewModel) {
        guard let navigationController = self.navigationController else {
            return
        }

        LastStepRouter.continueLearning(
            for: viewModel.course,
            isAdaptive: viewModel.isAdaptive,
            using: navigationController,
            source: viewModel.courseContinueSource,
            viewSource: viewModel.courseViewSource
        )
    }

    func displayAuthorization(viewModel: FullscreenCourseList.PresentAuthorization.ViewModel) {
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }

    func displayPaidCourseBuying(viewModel: FullscreenCourseList.PaidCourseBuyingPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURLString(
            viewModel.urlPath,
            inController: self,
            withKey: .paidCourse,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func displayProfile(viewModel: FullscreenCourseList.ProfilePresentation.ViewModel) {
        let assembly = NewProfileAssembly(otherUserID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }

    func displayFullscreenCourseList(viewModel: FullscreenCourseList.FullscreenCourseListModulePresentation.ViewModel) {
        let assembly = FullscreenCourseListAssembly(
            presentationDescription: viewModel.presentationDescription,
            courseListType: viewModel.courseListType
        )
        self.push(module: assembly.makeModule())
    }

    func displaySimilarAuthors(viewModel: FullscreenCourseList.SimilarAuthorsPresentation.ViewModel) {
        self.prepareCourseListModuleForSimilarCourseListsPresentation()
        self.refreshSimilarAuthorsCourseListState(.visible(ids: viewModel.ids))
    }

    func displaySimilarCourseLists(viewModel: FullscreenCourseList.SimilarCourseListsPresentation.ViewModel) {
        self.prepareCourseListModuleForSimilarCourseListsPresentation()
        self.refreshSimilarCourseListsState(.visible(ids: viewModel.ids))
    }

    // MARK: Private Helpers

    private func prepareCourseListModuleForSimilarCourseListsPresentation() {
        self.disableScrollForCourseListModule()
        self.loadAllCoursesInCourseListModule()
    }

    private func disableScrollForCourseListModule() {
        guard let submodule = self.getSubmodule(type: .courseList),
              let courseListView = submodule.view else {
            return
        }

        for subview in courseListView.subviews {
            guard let collectionView = subview as? UICollectionView else {
                continue
            }

            collectionView.isScrollEnabled = false
            self.fullscreenCourseListView?.observeCourseListCollectionViewContentSize(
                courseListView: courseListView,
                collectionView: collectionView
            )

            return
        }
    }

    private func loadAllCoursesInCourseListModule() {
        if let courseListSubmodule = self.getSubmodule(type: .courseList) {
            courseListSubmodule.courseListModuleInput?.loadAllCourses()
        }
    }
}

// MARK: - FullscreenCourseListViewController: CourseListFilterOutputProtocol -

extension FullscreenCourseListViewController: CourseListFilterOutputProtocol {
    func handleCourseListFilterDidFinishWithFilters(_ filters: [CourseListFilter.Filter]) {
        guard let courseListSubmodule = self.getSubmodule(type: .courseList) else {
            return
        }

        self.currentFilters = filters

        let hasChanges = filters != self.presentationDescription?.courseListFilterDescription?.prefilledFilters

        self.courseListFilterBarButtonItem.setActive(hasChanges)
        courseListSubmodule.courseListModuleInput?.applyFilters(hasChanges ? filters : [])
    }
}
