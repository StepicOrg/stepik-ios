import Pageboy
import UIKit

protocol CourseRevenueViewControllerProtocol: AnyObject {
    func displayCourseRevenue(viewModel: CourseRevenue.CourseRevenueLoad.ViewModel)
    func displayCourseInfo(viewModel: CourseRevenue.CourseInfoPresentation.ViewModel)
    func displayProfile(viewModel: CourseRevenue.ProfilePresentation.ViewModel)
}

final class CourseRevenueViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: CourseRevenueInteractorProtocol

    // Due to lazy initializing we should know actual values to update inset/offset of new scrollview
    private var lastKnownScrollOffset: CGFloat = 0
    private var lastKnownHeaderHeight: CGFloat = 0

    private lazy var pageViewController = PageboyViewController()

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var courseRevenueView: CourseRevenueView? { self.view as? CourseRevenueView }

    private let availableTabs: [CourseRevenue.Tab]
    private let initialTabIndex: Int

    private var state: CourseRevenue.ViewControllerState {
        didSet {
            self.updateState(newState: self.state)
        }
    }

    // Element is nil when view controller was not initialized yet
    private var submodulesControllers: [UIViewController?] = []
    private var submodulesInputs: [CourseRevenueSubmoduleProtocol?] = []

    init(
        interactor: CourseRevenueInteractorProtocol,
        availableTabs: [CourseRevenue.Tab],
        initialTab: CourseRevenue.Tab,
        initialState: CourseRevenue.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        self.availableTabs = availableTabs
        self.submodulesControllers = Array(repeating: nil, count: availableTabs.count)
        self.submodulesInputs = Array(repeating: nil, count: availableTabs.count)

        if let initialTabIndex = self.availableTabs.firstIndex(of: initialTab) {
            self.initialTabIndex = initialTabIndex
        } else {
            self.initialTabIndex = 0
        }

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0

        let appearance = CourseRevenueView.Appearance(headerTopOffset: statusBarHeight + navigationBarHeight)

        let view = CourseRevenueView(
            frame: UIScreen.main.bounds,
            pageControllerView: self.pageViewController.view,
            tabsTitles: self.availableTabs.map(\.title),
            appearance: appearance
        )
        view.delegate = self

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChild(self.pageViewController)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self

        self.courseRevenueView?.updateCurrentPageIndex(self.initialTabIndex)

        self.title = NSLocalizedString("CourseRevenueTitle", comment: "")

        self.automaticallyAdjustsScrollViewInsets = false

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.state = .loading
                    strongSelf.interactor.doCourseRevenueLoad(request: .init())
                }
            ),
            for: .connectionError
        )

        self.updateState(newState: self.state)
        self.interactor.doCourseRevenueLoad(request: .init())
    }

    // MARK: Private API

    private func updateState(newState: CourseRevenue.ViewControllerState) {
        switch newState {
        case .loading:
            self.isPlaceholderShown = false
            self.courseRevenueView?.setLoading(true)
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .empty(let viewModel):
            self.isPlaceholderShown = false
            self.courseRevenueView?.setLoading(false)
            self.courseRevenueView?.configure(viewModel: viewModel)
        case .result(let viewModel):
            self.isPlaceholderShown = false
            self.courseRevenueView?.setLoading(false)
            self.courseRevenueView?.configure(viewModel: viewModel)
        }
    }

    private func loadSubmoduleIfNeeded(at index: Int) {
        guard self.submodulesControllers[index] == nil else {
            return
        }

        guard let tab = self.availableTabs[safe: index] else {
            return
        }

        let moduleInput: CourseRevenueSubmoduleProtocol?
        let controller: UIViewController

        switch tab {
        case .purchasesAndRefunds:
            let assembly = CourseRevenueTabPurchasesAssembly(
                moduleOutput: self.interactor as? CourseRevenueTabPurchasesOutputProtocol
            )
            controller = assembly.makeModule()
            moduleInput = assembly.moduleInput
        case .payments:
            controller = UIViewController()
            moduleInput = nil
        }

        self.submodulesControllers[index] = controller
        self.submodulesInputs[index] = moduleInput

        if let submodule = moduleInput {
            self.interactor.doSubmodulesRegistration(request: .init(submodules: [index: submodule]))
        }
    }

    private func updateContentInset(headerHeight: CGFloat) {
        // Update contentInset for each page
        for viewController in self.submodulesControllers {
            guard let viewController = viewController else {
                continue
            }

            let view = viewController.view as? ScrollablePageViewProtocol

            if let view = view {
                view.contentInsets = UIEdgeInsets(
                    top: headerHeight,
                    left: view.contentInsets.left,
                    bottom: view.contentInsets.bottom,
                    right: view.contentInsets.right
                )
                view.scrollViewDelegate = self
            }

            viewController.view.setNeedsLayout()
            viewController.view.layoutIfNeeded()

            view?.contentInsetAdjustmentBehavior = .never
        }
    }

    private func updateContentOffset(scrollOffset: CGFloat) {
        guard let courseRevenueView = self.courseRevenueView else {
            return
        }

        let navigationBarHeight = self.navigationController?.navigationBar.bounds.height
        let statusBarHeight = min(
            UIApplication.shared.statusBarFrame.size.width,
            UIApplication.shared.statusBarFrame.size.height
        )
        let topPadding = (navigationBarHeight ?? 0) + statusBarHeight

        let offsetWithHeader = scrollOffset
            - topPadding
            + courseRevenueView.headerHeight
            + courseRevenueView.appearance.segmentedControlHeight

        let headerHeight = courseRevenueView.headerHeight - topPadding * 2

        // Pin segmented control
        let scrollViewOffset = min(offsetWithHeader, headerHeight)
        courseRevenueView.updateScroll(offset: scrollViewOffset)

        // Arrange page views contentOffset
        let offsetWithHiddenHeader = -(topPadding + courseRevenueView.appearance.segmentedControlHeight)
        self.arrangePagesScrollOffset(
            topOffsetOfCurrentTab: scrollOffset,
            maxTopOffset: offsetWithHiddenHeader
        )
    }

    private func arrangePagesScrollOffset(topOffsetOfCurrentTab: CGFloat, maxTopOffset: CGFloat) {
        for viewController in self.submodulesControllers {
            guard let view = viewController?.view as? ScrollablePageViewProtocol else {
                continue
            }

            var topOffset = view.contentOffset.y

            // Scrolling down
            if topOffset != topOffsetOfCurrentTab && topOffset <= maxTopOffset {
                topOffset = min(topOffsetOfCurrentTab, maxTopOffset)
            }

            // Scrolling up
            if topOffset > maxTopOffset && topOffsetOfCurrentTab <= maxTopOffset {
                topOffset = min(topOffsetOfCurrentTab, maxTopOffset)
            }

            view.contentOffset = CGPoint(
                x: view.contentOffset.x,
                y: topOffset
            )
        }
    }
}

extension CourseRevenueViewController: PageboyViewControllerDataSource, PageboyViewControllerDelegate {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        self.availableTabs.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        self.loadSubmoduleIfNeeded(at: index)
        self.updateContentOffset(scrollOffset: self.lastKnownScrollOffset)
        self.updateContentInset(headerHeight: self.lastKnownHeaderHeight)
        return self.submodulesControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        .at(index: self.initialTabIndex)
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {
        self.courseRevenueView?.updateCurrentPageIndex(index)
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        willScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {}

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollTo position: CGPoint,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {}

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didReloadWith currentViewController: UIViewController,
        currentPageIndex: PageboyViewController.PageIndex
    ) {}
}

extension CourseRevenueViewController: CourseRevenueViewControllerProtocol {
    func displayCourseRevenue(viewModel: CourseRevenue.CourseRevenueLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayCourseInfo(viewModel: CourseRevenue.CourseInfoPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(courseID: viewModel.courseID, courseViewSource: .unknown)
        self.push(module: assembly.makeModule())
    }

    func displayProfile(viewModel: CourseRevenue.ProfilePresentation.ViewModel) {
        let assembly = NewProfileAssembly(otherUserID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }
}

extension CourseRevenueViewController: CourseRevenueViewDelegate {
    func numberOfPages(in courseRevenueView: CourseRevenueView) -> Int {
        self.submodulesControllers.count
    }

    func courseRevenueView(_ courseRevenueView: CourseRevenueView, didReportNewHeaderHeight height: CGFloat) {
        self.lastKnownHeaderHeight = height
        self.updateContentInset(headerHeight: self.lastKnownHeaderHeight)
    }

    func courseRevenueView(_ courseRevenueView: CourseRevenueView, didClickSummary expanded: Bool) {
        self.interactor.doCourseSummaryClickAction(request: .init(expanded: expanded))
    }

    func courseRevenueView(_ courseRevenueView: CourseRevenueView, didRequestScrollToPage index: Int) {
        self.pageViewController.scrollToPage(.at(index: index), animated: true)
    }
}

extension CourseRevenueViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastKnownScrollOffset = scrollView.contentOffset.y
        self.updateContentOffset(scrollOffset: self.lastKnownScrollOffset)
    }
}
