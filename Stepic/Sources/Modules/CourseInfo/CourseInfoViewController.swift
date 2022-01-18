import Pageboy
import Presentr
import SVProgressHUD
import UIKit

// swiftlint:disable file_length
protocol CourseInfoViewControllerProtocol: AnyObject {
    func displayCourse(viewModel: CourseInfo.CourseLoad.ViewModel)
    func displayLesson(viewModel: CourseInfo.LessonPresentation.ViewModel)
    func displayPersonalDeadlinesSettings(viewModel: CourseInfo.PersonalDeadlinesSettingsPresentation.ViewModel)
    func displayExamLesson(viewModel: CourseInfo.ExamLessonPresentation.ViewModel)
    func displayCourseSharing(viewModel: CourseInfo.CourseShareAction.ViewModel)
    func displayLastStep(viewModel: CourseInfo.LastStepPresentation.ViewModel)
    func displayPurchaseModalStartLearning(viewModel: CourseInfo.PurchaseModalStartLearningPresentation.ViewModel)
    func displayLessonModuleBuyCourseAction(viewModel: CourseInfo.LessonModuleBuyCourseActionPresentation.ViewModel)
    func displayLessonModuleCatalogAction(viewModel: CourseInfo.LessonModuleCatalogPresentation.ViewModel)
    func displayLessonModuleWriteReviewAction(viewModel: CourseInfo.LessonModuleWriteReviewPresentation.ViewModel)
    func displayPreviewLesson(viewModel: CourseInfo.PreviewLessonPresentation.ViewModel)
    func displayCourseRevenue(viewModel: CourseInfo.CourseRevenuePresentation.ViewModel)
    func displayAuthorization(viewModel: CourseInfo.AuthorizationPresentation.ViewModel)
    func displayPaidCourseBuying(viewModel: CourseInfo.PaidCourseBuyingPresentation.ViewModel)
    func displayPaidCoursePurchaseModal(viewModel: CourseInfo.PaidCoursePurchaseModalPresentation.ViewModel)
    func displayPaidCourseRestorePurchaseResult(viewModel: CourseInfo.PaidCourseRestorePurchase.ViewModel)
    func displayIAPNotAllowed(viewModel: CourseInfo.IAPNotAllowedPresentation.ViewModel)
    func displayIAPReceiptValidationFailed(viewModel: CourseInfo.IAPReceiptValidationFailedPresentation.ViewModel)
    func displayIAPPaymentFailed(viewModel: CourseInfo.IAPPaymentFailedPresentation.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: CourseInfo.BlockingWaitingIndicatorUpdate.ViewModel)
    func displayUserCourseActionResult(viewModel: CourseInfo.UserCourseActionPresentation.ViewModel)
    func displayWishlistMainActionResult(viewModel: CourseInfo.CourseWishlistMainAction.ViewModel)
    func displayCourseContentSearch(viewModel: CourseInfo.CourseContentSearchPresentation.ViewModel)
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

    private lazy var searchBarButton = UIBarButtonItem(
        barButtonSystemItem: .search,
        target: self,
        action: #selector(self.searchButtonClicked)
    )

    private lazy var wishlistBarButton = UIBarButtonItem(
        image: nil,
        style: .plain,
        target: self,
        action: #selector(self.wishlistButtonClicked)
    )

    private lazy var moreBarButton = UIBarButtonItem(
        image: UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(self.actionButtonClicked)
    )

    private lazy var restorePurchaseErrorContactSupportController = ContactSupportController(
        subject: NSLocalizedString("CourseInfoPurchaseModalPurchaseErrorContactSupportSubject", comment: ""),
        presentationController: self
    )

    // Element is nil when view controller was not initialized yet
    private var submodulesControllers: [UIViewController?] = []
    private var submodulesInputs: [CourseInfoSubmoduleProtocol?] = []

    private var storedViewModel: CourseInfoHeaderViewModel?
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChild(self.pageViewController)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self

        self.courseInfoView?.updateCurrentPageIndex(self.initialTabIndex)

        self.title = NSLocalizedString("CourseInfoTitle", comment: "")

        self.navigationItem.rightBarButtonItems = [self.moreBarButton]
        self.styledNavigationController?.removeBackButtonTitleForTopController()

        self.automaticallyAdjustsScrollViewInsets = false

        self.updateState(newState: .loading)
        self.interactor.doCourseRefresh(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.interactor.doOnlineModeReset(request: .init())
        self.interactor.doPurchaseCourseNotificationUpdate(request: .init())

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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            // Update status bar style.
            self.updateContentOffset(scrollOffset: self.lastKnownScrollOffset)
        }
    }

    private func updateState(newState: CourseInfo.ViewControllerState) {
        switch newState {
        case .result(let data):
            self.moreBarButton.isEnabled = true
            self.courseInfoView?.setErrorPlaceholderVisible(false)
            self.courseInfoView?.setLoading(false)

            if data.isWishlistAvailable {
                self.navigationItem.rightBarButtonItems = [self.moreBarButton, self.wishlistBarButton]
                let wishlistImageName = data.isWishlisted ? "wishlist-like-filled" : "wishlist-like"
                self.wishlistBarButton.image = UIImage(named: wishlistImageName)?.withRenderingMode(.alwaysTemplate)
            } else {
                self.navigationItem.rightBarButtonItems = [self.moreBarButton, self.searchBarButton]
            }

            let isFirstLoadedResult = self.storedViewModel == nil

            self.storedViewModel = data
            self.courseInfoView?.configure(viewModel: data)

            if isFirstLoadedResult {
                DispatchQueue.main.async {
                    let headerHeight = (self.courseInfoView?.headerHeight ?? 0)
                        + (self.courseInfoView?.appearance.segmentedControlHeight ?? 0)
                    self.updateContentOffset(scrollOffset: -headerHeight)
                    self.updateContentInset(headerHeight: headerHeight)
                }
            }
        case .loading:
            self.moreBarButton.isEnabled = false
            self.courseInfoView?.setErrorPlaceholderVisible(false)
            self.courseInfoView?.setLoading(true)
        case .error:
            self.updateTopBar(alpha: 1)
            self.moreBarButton.isEnabled = false
            self.courseInfoView?.setErrorPlaceholderVisible(true)
            self.courseInfoView?.setLoading(false)
        }
    }

    private func updateTopBar(alpha: CGFloat) {
        self.view.performBlockUsingViewTraitCollection {
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

            let statusBarStyle: UIStatusBarStyle = {
                if alpha > CGFloat(CourseInfoViewController.topBarAlphaStatusBarThreshold) {
                    return self.view.isDarkInterfaceStyle ? .lightContent : .dark
                } else {
                    return .lightContent
                }
            }()

            self.styledNavigationController?.changeStatusBarStyle(statusBarStyle, sender: self)
        }
    }

    private func loadSubmoduleIfNeeded(at index: Int) {
        guard self.submodulesControllers[index] == nil else {
            return
        }

        guard let tab = self.availableTabs[safe: index] else {
            return
        }

        let controller: UIViewController
        let moduleInput: CourseInfoSubmoduleProtocol?

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
        case .news:
            let assembly = CourseInfoTabNewsAssembly()
            controller = assembly.makeModule()
            moduleInput = assembly.moduleInput
        }

        self.submodulesControllers[index] = controller
        self.submodulesInputs[index] = moduleInput

        if let submodule = moduleInput {
            self.interactor.doSubmodulesRegistration(request: .init(submodules: [index: submodule]))
        }
    }

    @objc
    private func searchButtonClicked() {
        self.interactor.doCourseContentSearchPresentation(request: .init())
    }

    @objc
    private func wishlistButtonClicked() {
        self.interactor.doWishlistMainAction(request: .init())
    }

    @objc
    private func actionButtonClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if self.storedViewModel?.isRestorePurchaseAvailable ?? false {
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("CourseInfoRestorePurchaseTitle", comment: ""),
                    style: .default,
                    handler: { [weak self] _ in
                        self?.interactor.doRestorePurchase(request: .init())
                    }
                )
            )
        }

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Share", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.interactor.doCourseShareAction(request: .init())
                }
            )
        )

        if self.storedViewModel?.isRevenueAvailable ?? false {
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("CourseInfoCourseActionViewRevenueAlertTitle", comment: ""),
                    style: .default,
                    handler: { [weak self] _ in
                        self?.interactor.doCourseRevenuePresentation(request: .init())
                    }
                )
            )
        }

        if let viewModel = self.storedViewModel, viewModel.isEnrolled {
            let favoriteActionTitle = viewModel.isFavorite
                ? NSLocalizedString("CourseInfoCourseActionRemoveFromFavoritesAlertTitle", comment: "")
                : NSLocalizedString("CourseInfoCourseActionAddToFavoritesAlertTitle", comment: "")
            alert.addAction(
                UIAlertAction(
                    title: favoriteActionTitle,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.interactor.doCourseFavoriteAction(request: .init())
                    }
                )
            )

            let archivedActionTitle = viewModel.isArchived
                ? NSLocalizedString("CourseInfoCourseActionRemoveFromArchivedAlertTitle", comment: "")
                : NSLocalizedString("CourseInfoCourseActionMoveToArchivedAlertTitle", comment: "")
            alert.addAction(
                UIAlertAction(
                    title: archivedActionTitle,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.interactor.doCourseArchiveAction(request: .init())
                    }
                )
            )

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

// MARK: - CourseInfoViewController: PageboyViewControllerDataSource, PageboyViewControllerDelegate -

extension CourseInfoViewController: PageboyViewControllerDataSource, PageboyViewControllerDelegate {
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
        self.courseInfoView?.updateCurrentPageIndex(index)
        self.interactor.doSubmoduleControllerAppearanceUpdate(request: .init(submoduleIndex: index))
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

// MARK: - CourseInfoViewController: CourseInfoViewControllerProtocol -

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
                    WebControllerManager.shared.presentWebControllerWithURLString(
                        "\(viewModel.urlPath)?from_mobile_app=true",
                        inController: strongSelf,
                        withKey: .exam,
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
        self.updateState(newState: viewModel.state)
    }

    func displayLesson(viewModel: CourseInfo.LessonPresentation.ViewModel) {
        let assembly = LessonAssembly(
            initialContext: .unit(id: viewModel.unitID),
            promoCodeName: viewModel.promoCodeName,
            moduleOutput: self.interactor as? LessonOutputProtocol
        )
        self.push(module: assembly.makeModule())
    }

    func displayPersonalDeadlinesSettings(viewModel: CourseInfo.PersonalDeadlinesSettingsPresentation.ViewModel) {
        switch viewModel.action {
        case .create:
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
        case .edit:
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

    func displayUserCourseActionResult(viewModel: CourseInfo.UserCourseActionPresentation.ViewModel) {
        if viewModel.isSuccessful {
            SVProgressHUD.showSuccess(withStatus: viewModel.message)
        } else {
            SVProgressHUD.showError(withStatus: viewModel.message)
        }
    }

    func displayWishlistMainActionResult(viewModel: CourseInfo.CourseWishlistMainAction.ViewModel) {
        if viewModel.isSuccessful {
            SVProgressHUD.showSuccess(withStatus: viewModel.message)
        } else {
            SVProgressHUD.showError(withStatus: viewModel.message)
        }
    }

    func displayCourseContentSearch(viewModel: CourseInfo.CourseContentSearchPresentation.ViewModel) {
        let assembly = CourseSearchAssembly(courseID: viewModel.courseID)
        self.push(module: assembly.makeModule())
    }

    func displayLastStep(viewModel: CourseInfo.LastStepPresentation.ViewModel) {
        self.continueLearning(
            course: viewModel.course,
            isAdaptive: viewModel.isAdaptive,
            courseViewSource: viewModel.courseViewSource
        )
    }

    func displayPurchaseModalStartLearning(viewModel: CourseInfo.PurchaseModalStartLearningPresentation.ViewModel) {
        self.dismiss(animated: true) { [weak self] in
            self?.continueLearning(
                course: viewModel.course,
                isAdaptive: viewModel.isAdaptive,
                courseViewSource: viewModel.courseViewSource
            )
        }
    }

    func displayLessonModuleBuyCourseAction(viewModel: CourseInfo.LessonModuleBuyCourseActionPresentation.ViewModel) {
        if self.popLessonViewController() != nil {
            DispatchQueue.main.async {
                self.interactor.doMainCourseAction(request: .init(courseBuySource: .demoLessonDialog))
            }
        }
    }

    func displayLessonModuleCatalogAction(viewModel: CourseInfo.LessonModuleCatalogPresentation.ViewModel) {
        if self.popLessonViewController() != nil {
            DispatchQueue.main.async {
                TabBarRouter(tab: .catalog(searchCourses: false)).route()
            }
        }
    }

    func displayLessonModuleWriteReviewAction(viewModel: CourseInfo.LessonModuleWriteReviewPresentation.ViewModel) {
        if self.popLessonViewController() != nil {
            guard let tabIndex = self.availableTabs.firstIndex(of: .reviews) else {
                return
            }

            self.pageViewController.scrollToPage(.at(index: tabIndex), animated: true) { _, _, _ in
                for submoduleInput in self.submodulesInputs {
                    if let reviewsModuleInput = submoduleInput as? CourseInfoTabReviewsInputProtocol {
                        reviewsModuleInput.presentWriteCourseReview()
                        return
                    }
                }
            }
        }
    }

    func displayPreviewLesson(viewModel: CourseInfo.PreviewLessonPresentation.ViewModel) {
        let initialContext: LessonDataFlow.Context = {
            if let previewUnitID = viewModel.previewUnitID {
                return .unit(id: previewUnitID)
            }
            return .lesson(id: viewModel.previewLessonID)
        }()

        let assembly = LessonAssembly(
            initialContext: initialContext,
            promoCodeName: viewModel.promoCodeName,
            moduleOutput: self.interactor as? LessonOutputProtocol
        )

        self.push(module: assembly.makeModule())
    }

    func displayCourseRevenue(viewModel: CourseInfo.CourseRevenuePresentation.ViewModel) {
        let assembly = CourseRevenueAssembly(courseID: viewModel.courseID)
        self.push(module: assembly.makeModule())
    }

    func displayAuthorization(viewModel: CourseInfo.AuthorizationPresentation.ViewModel) {
        RoutingManager.auth.routeFrom(
            controller: self,
            success: { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                // Refresh course state and continue learning
                strongSelf.interactor.doCourseRefresh(request: .init())
                strongSelf.interactor.doMainCourseAction(request: .init())
            },
            cancel: nil
        )
    }

    func displayPaidCourseBuying(viewModel: CourseInfo.PaidCourseBuyingPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURLString(
            viewModel.urlPath,
            inController: self,
            withKey: .paidCourse,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func displayPaidCoursePurchaseModal(viewModel: CourseInfo.PaidCoursePurchaseModalPresentation.ViewModel) {
        let assembly = CourseInfoPurchaseModalAssembly(
            courseID: viewModel.courseID,
            promoCodeName: viewModel.promoCodeName,
            mobileTierID: viewModel.mobileTierID,
            courseBuySource: viewModel.courseBuySource,
            output: self.interactor as? CourseInfoPurchaseModalOutputProtocol
        )
        self.presentIfPanModalWithCustomModalPresentationStyle(assembly.makeModule())
    }

    func displayPaidCourseRestorePurchaseResult(viewModel: CourseInfo.PaidCourseRestorePurchase.ViewModel) {
        switch viewModel.state {
        case .inProgress:
            SVProgressHUD.show()
        case .error(let title, let message):
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("CourseInfoRestorePurchaseAlertCancelTitle", comment: ""),
                    style: .cancel
                )
            )
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("CourseInfoRestorePurchaseAlertContactSupportTitle", comment: ""),
                    style: .default,
                    handler: { [weak self] _ in
                        self?.restorePurchaseErrorContactSupportController.contactSupport()
                    }
                )
            )
            self.present(module: alert)
        case .success(let message):
            SVProgressHUD.showSuccess(withStatus: message)
        }
    }

    func displayIAPNotAllowed(viewModel: CourseInfo.IAPNotAllowedPresentation.ViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("IAPPurchaseBuyInWeb", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.displayPaidCourseBuying(viewModel: .init(urlPath: viewModel.urlPath))
                }
            )
        )
        self.present(module: alert)
    }

    func displayIAPReceiptValidationFailed(viewModel: CourseInfo.IAPReceiptValidationFailedPresentation.ViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("PlaceholderNoConnectionButton", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.interactor.doIAPReceiptValidationRetry(request: .init())
                }
            )
        )
        self.present(module: alert)
    }

    func displayIAPPaymentFailed(viewModel: CourseInfo.IAPPaymentFailedPresentation.ViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(module: alert)
    }

    // MARK: Private Helpers

    private func continueLearning(
        course: Course,
        isAdaptive: Bool,
        courseViewSource: AnalyticsEvent.CourseViewSource
    ) {
        guard let navigationController = self.navigationController else {
            return
        }

        LastStepRouter.continueLearning(
            for: course,
            isAdaptive: isAdaptive,
            using: navigationController,
            skipSyllabus: true,
            source: .courseScreen,
            viewSource: courseViewSource,
            lessonModuleOutput: self.interactor as? LessonOutputProtocol
        )
    }

    private func popLessonViewController() -> UIViewController? {
        guard let navigationController = self.navigationController,
              navigationController.topViewController as? LessonViewControllerProtocol != nil else {
            return nil
        }

        return navigationController.popViewController(animated: true)
    }
}

// MARK: - CourseInfoViewController: CourseInfoViewDelegate -

extension CourseInfoViewController: CourseInfoViewDelegate {
    func numberOfPages(in courseInfoView: CourseInfoView) -> Int {
        self.submodulesControllers.count
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

    func courseInfoViewDidTryForFreeAction(_ courseInfoView: CourseInfoView) {
        self.interactor.doPreviewLessonPresentation(request: .init())
    }

    func courseInfoViewDidPlaceholderAction(_ view: CourseInfoView) {
        self.updateTopBar(alpha: 0)
        self.updateState(newState: .loading)
        self.interactor.doCourseRefresh(request: .init())
    }
}

// MARK: - CourseInfoViewController: UIScrollViewDelegate -

extension CourseInfoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastKnownScrollOffset = scrollView.contentOffset.y
        self.updateContentOffset(scrollOffset: self.lastKnownScrollOffset)
    }
}

// MARK: - CourseInfoViewController: StyledNavigationControllerPresentable -

extension CourseInfoViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        .init(
            shadowViewAlpha: 0.0,
            backgroundColor: StyledNavigationController.Appearance.backgroundColor.withAlphaComponent(0.0),
            statusBarColor: StyledNavigationController.Appearance.statusBarColor.withAlphaComponent(0.0),
            textColor: StyledNavigationController.Appearance.tintColor.withAlphaComponent(0.0),
            tintColor: .white,
            statusBarStyle: .lightContent
        )
    }
}
