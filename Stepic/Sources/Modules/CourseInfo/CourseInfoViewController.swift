import Pageboy
import Presentr
import SVProgressHUD
import UIKit

protocol CourseInfoScrollablePageViewProtocol: class {
    var scrollViewDelegate: UIScrollViewDelegate? { get set }
    var contentInsets: UIEdgeInsets { get set }
    var contentOffset: CGPoint { get set }

    @available(iOS 11.0, *)
    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior { get set }
}

protocol CourseInfoViewControllerProtocol: class {
    func displayCourse(viewModel: CourseInfo.CourseLoad.ViewModel)
    func displayLesson(viewModel: CourseInfo.LessonPresentation.ViewModel)
    func displayPersonalDeadlinesSettings(viewModel: CourseInfo.PersonalDeadlinesSettingsPresentation.ViewModel)
    func displayExamLesson(viewModel: CourseInfo.ExamLessonPresentation.ViewModel)
    func displayCourseSharing(viewModel: CourseInfo.CourseShareAction.ViewModel)
    func displayLastStep(viewModel: CourseInfo.LastStepPresentation.ViewModel)
    func displayAuthorization(viewModel: CourseInfo.AuthorizationPresentation.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: CourseInfo.BlockingWaitingIndicatorUpdate.ViewModel)
}

final class CourseInfoViewController: UIViewController {
    private static let topBarAlphaStatusBarThreshold = 0.85

    private let availableTabs: [CourseInfo.Tab]
    private let initialTabIndex: Int

    private let interactor: CourseInfoInteractorProtocol

    // Due to lazy initializing we should know actual values to update inset/offset of new scrollview
    private var lastKnownScrollOffset: CGFloat = 0
    private var lastKnownHeaderHeight: CGFloat = 0

    private lazy var pageViewController = PageboyViewController()

    lazy var courseInfoView = self.view as? CourseInfoView
    lazy var styledNavigationController = self.navigationController as? StyledNavigationController

    private lazy var moreBarButton = UIBarButtonItem(
        image: UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(self.actionButtonClicked)
    )

    // Element is nil when view controller was not initialized yet
    private var submodulesControllers: [UIViewController?] = []

    private var shouldShowDropCourseAction = false
    private let didJustSubscribe: Bool

    init(
        interactor: CourseInfoInteractorProtocol,
        availableTabs: [CourseInfo.Tab],
        initialTab: CourseInfo.Tab,
        didJustSubscribe: Bool = false
    ) {
        self.interactor = interactor
        self.didJustSubscribe = didJustSubscribe

        self.availableTabs = availableTabs
        self.submodulesControllers = Array(repeating: nil, count: availableTabs.count)

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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChild(self.pageViewController)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self

        self.courseInfoView?.updateCurrentPageIndex(self.initialTabIndex)

        self.title = NSLocalizedString("CourseInfoTitle", comment: "")

        self.navigationItem.rightBarButtonItem = self.moreBarButton
        self.styledNavigationController?.removeBackButtonTitleForTopController()

        if #available(iOS 11.0, *) { } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        self.interactor.doCourseRefresh(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.interactor.doOnlineModeReset(request: .init())

        if self.didJustSubscribe {
            NotificationPermissionStatus.current.done { status in
                if status == .notDetermined {
                    self.interactor.doRegistrationForRemoteNotifications(request: .init())
                }
            }
        }
    }

    override func loadView() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0

        let appearance = CourseInfoView.Appearance(headerTopOffset: statusBarHeight + navigationBarHeight)

        let view = CourseInfoView(
            frame: UIScreen.main.bounds,
            pageControllerView: self.pageViewController.view,
            scrollDelegate: self,
            tabsTitles: self.availableTabs.map { $0.title },
            appearance: appearance
        )
        view.delegate = self

        self.view = view
    }

    private func updateTopBar(alpha: CGFloat) {
        self.styledNavigationController?.changeBackgroundColor(
            StyledNavigationController.Appearance.backgroundColor.withAlphaComponent(alpha),
            sender: self
        )

        let transitionColor = ColorTransitionHelper.makeTransitionColor(
            from: .white,
            to: StyledNavigationController.Appearance.tintColor,
            transitionProgress: alpha
        )
        self.styledNavigationController?.changeTintColor(transitionColor, sender: self)
        self.styledNavigationController?.changeTextColor(
            StyledNavigationController.Appearance.tintColor.withAlphaComponent(alpha),
            sender: self
        )

        let statusBarStyle = alpha > CGFloat(CourseInfoViewController.topBarAlphaStatusBarThreshold)
            ? UIStatusBarStyle.default
            : UIStatusBarStyle.lightContent
        self.styledNavigationController?.changeStatusBarStyle(statusBarStyle, sender: self)
    }

    private func loadSubmoduleIfNeeded(at index: Int) {
        guard self.submodulesControllers[index] == nil else {
            return
        }

        guard let tab = self.availableTabs[safe: index] else {
            return
        }

        let moduleInput: CourseInfoSubmoduleProtocol?
        let controller: UIViewController
        switch tab {
        case .info:
            let assembly = CourseInfoTabInfoAssembly()
            controller = assembly.makeModule()
            moduleInput = assembly.moduleInput
        case .syllabus:
            let assembly = CourseInfoTabSyllabusAssembly(
                output: self.interactor as? CourseInfoTabSyllabusOutputProtocol
            )
            controller = assembly.makeModule()
            moduleInput = assembly.moduleInput
        case .reviews:
            let assembly = CourseInfoTabReviewsAssembly()
            controller = assembly.makeModule()
            moduleInput = assembly.moduleInput
        }

        self.submodulesControllers[index] = controller

        if let submodule = moduleInput {
            self.interactor.doSubmodulesRegistration(request: .init(submodules: [index: submodule]))
        }
    }

    @objc
    private func actionButtonClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Share", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.interactor.doCourseShareAction(request: .init())
                }
            )
        )

        if self.shouldShowDropCourseAction {
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("DropCourse", comment: ""),
                    style: .destructive,
                    handler: { [weak self] _ in
                        self?.interactor.doCourseUnenrollmentAction(request: .init())
                    }
                )
            )
        }

        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        )
        alert.popoverPresentationController?.barButtonItem = self.moreBarButton
        self.present(module: alert)
    }

    // Update content inset (to make header visible)
    private func updateContentInset(headerHeight: CGFloat) {
        // Update contentInset for each page
        for viewController in self.submodulesControllers {
            guard let viewController = viewController else {
                continue
            }

            let view = viewController.view as? CourseInfoScrollablePageViewProtocol

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

            if #available(iOS 11.0, *) {
                view?.contentInsetAdjustmentBehavior = .never
            } else {
                viewController.automaticallyAdjustsScrollViewInsets = false
            }
        }
    }

    // Update content offset (to update appearance and offset on each tab)
    private func updateContentOffset(scrollOffset: CGFloat) {
        guard let courseInfoView = self.courseInfoView else {
            return
        }

        let navigationBarHeight = self.navigationController?.navigationBar.bounds.height
        let statusBarHeight = min(
            UIApplication.shared.statusBarFrame.size.width,
            UIApplication.shared.statusBarFrame.size.height
        )
        let topPadding = (navigationBarHeight ?? 0) + statusBarHeight

        let offsetWithHeader = scrollOffset
            + courseInfoView.headerHeight
            + courseInfoView.appearance.segmentedControlHeight
        let headerHeight = courseInfoView.headerHeight - topPadding

        let scrollingProgress = max(0, min(1, offsetWithHeader / headerHeight))
        self.updateTopBar(alpha: scrollingProgress)

        // Pin segmented control
        let scrollViewOffset = min(offsetWithHeader, headerHeight)
        courseInfoView.updateScroll(offset: scrollViewOffset)

        // Arrange page views contentOffset
        let offsetWithHiddenHeader = -(topPadding + courseInfoView.appearance.segmentedControlHeight)
        self.arrangePagesScrollOffset(
            topOffsetOfCurrentTab: scrollOffset,
            maxTopOffset: offsetWithHiddenHeader
        )
    }

    private func arrangePagesScrollOffset(topOffsetOfCurrentTab: CGFloat, maxTopOffset: CGFloat) {
        for viewController in self.submodulesControllers {
            guard let view = viewController?.view as? CourseInfoScrollablePageViewProtocol else {
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

extension CourseInfoViewController: PageboyViewControllerDataSource, PageboyViewControllerDelegate {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return self.availableTabs.count
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
        return .at(index: self.initialTabIndex)
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {
        self.courseInfoView?.updateCurrentPageIndex(index)
        self.interactor.doSubmoduleControllerAppearanceUpdate(request: .init(submoduleIndex: index))
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        willScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) { }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollTo position: CGPoint,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) { }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didReloadWith currentViewController: UIViewController,
        currentPageIndex: PageboyViewController.PageIndex
    ) { }
}

extension CourseInfoViewController: CourseInfoViewControllerProtocol {
    func displayExamLesson(viewModel: CourseInfo.ExamLessonPresentation.ViewModel) {
        let alert = UIAlertController(
            title: NSLocalizedString("ExamTitle", comment: ""),
            message: NSLocalizedString("ShowExamInWeb", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Open", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }
                    WebControllerManager.sharedManager.presentWebControllerWithURLString(
                        "\(viewModel.urlPath)?from_mobile_app=true",
                        inController: strongSelf,
                        withKey: "exam",
                        allowsSafari: true,
                        backButtonStyle: .close
                    )
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil
            )
        )
        self.present(module: alert)
    }

    func displayCourseSharing(viewModel: CourseInfo.CourseShareAction.ViewModel) {
        let sharingViewController = SharingHelper.getSharingController(viewModel.urlPath)
        sharingViewController.popoverPresentationController?.barButtonItem = self.moreBarButton
        self.present(module: sharingViewController)
    }

    func displayCourse(viewModel: CourseInfo.CourseLoad.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.courseInfoView?.configure(viewModel: data)
            self.shouldShowDropCourseAction = data.isEnrolled
        case .loading:
            break
        }
    }

    func displayLesson(viewModel: CourseInfo.LessonPresentation.ViewModel) {
        let assembly: Assembly = {
            if RemoteConfig.shared.newLessonAvailable {
                return NewLessonAssembly(initialContext: .unit(id: viewModel.unitID))
            } else {
                return LessonLegacyAssembly(
                    initObjects: viewModel.initObjects,
                    initIDs: viewModel.initIDs
                )
            }
        }()

        self.push(module: assembly.makeModule())
    }

    func displayPersonalDeadlinesSettings(viewModel: CourseInfo.PersonalDeadlinesSettingsPresentation.ViewModel) {
        if viewModel.action == .create {
            // Show popup
            let presentr: Presentr = {
                let presenter = Presentr(presentationType: .dynamic(center: .center))
                presenter.roundCorners = true
                return presenter
            }()

            let viewController = PersonalDeadlinesModeSelectionLegacyAssembly(
                course: viewModel.course,
                updateCompletion: { [weak self] in
                    self?.interactor.doCourseRefresh(request: .init())
                }
            ).makeModule()
            self.customPresentViewController(
                presentr,
                viewController: viewController,
                animated: true
            )
        } else {
            // Show action sheet
            let viewController = PersonalDeadlineEditDeleteAlertLegacyAssembly(
                course: viewModel.course,
                presentingViewController: self,
                updateCompletion: { [weak self] in
                    self?.interactor.doCourseRefresh(request: .init())
                }
            ).makeModule()
            viewController.popoverPresentationController?.barButtonItem = self.moreBarButton
            self.present(module: viewController)
        }
    }

    func displayBlockingLoadingIndicator(viewModel: CourseInfo.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }

    func displayLastStep(viewModel: CourseInfo.LastStepPresentation.ViewModel) {
        guard let navigationController = self.navigationController else {
            return
        }

        LastStepRouter.continueLearning(
            for: viewModel.course,
            isAdaptive: viewModel.isAdaptive,
            using: navigationController,
            skipSyllabus: true
        )
    }

    func displayAuthorization(viewModel: CourseInfo.AuthorizationPresentation.ViewModel) {
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }
}

extension CourseInfoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastKnownScrollOffset = scrollView.contentOffset.y
        self.updateContentOffset(scrollOffset: self.lastKnownScrollOffset)
    }
}

extension CourseInfoViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        return .init(
            shadowViewAlpha: 0.0,
            backgroundColor: StyledNavigationController.Appearance.backgroundColor.withAlphaComponent(0.0),
            textColor: StyledNavigationController.Appearance.tintColor.withAlphaComponent(0.0),
            tintColor: .white,
            statusBarStyle: .lightContent
        )
    }
}

extension CourseInfoViewController: CourseInfoViewDelegate {
    func numberOfPages(in courseInfoView: CourseInfoView) -> Int {
        return self.submodulesControllers.count
    }

    func courseInfoView(_ courseInfoView: CourseInfoView, didReportNewHeaderHeight height: CGFloat) {
        self.lastKnownHeaderHeight = height
        self.updateContentInset(headerHeight: self.lastKnownHeaderHeight)
    }

    func courseInfoView(_ courseInfoView: CourseInfoView, didRequestScrollToPage index: Int) {
        self.pageViewController.scrollToPage(.at(index: index), animated: true)
    }

    func courseInfoViewDidMainAction(_ courseInfoView: CourseInfoView) {
        self.interactor.doMainCourseAction(request: .init())
    }
}
