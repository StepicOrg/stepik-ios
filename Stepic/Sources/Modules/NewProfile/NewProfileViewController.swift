import UIKit

// swiftlint:disable file_length
protocol NewProfileViewControllerProtocol: AnyObject {
    func displayProfile(viewModel: NewProfile.ProfileLoad.ViewModel)
    func displayNavigationControls(viewModel: NewProfile.NavigationControlsPresentation.ViewModel)
    func displaySubmoduleEmptyState(viewModel: NewProfile.SubmoduleEmptyStatePresentation.ViewModel)
    func displayAuthorization(viewModel: NewProfile.AuthorizationPresentation.ViewModel)
    func displayProfileSharing(viewModel: NewProfile.ProfileShareAction.ViewModel)
    func displayProfileEditing(viewModel: NewProfile.ProfileEditAction.ViewModel)
    func displayAchievementsList(viewModel: NewProfile.AchievementsListPresentation.ViewModel)
    func displayCertificatesList(viewModel: NewProfile.CertificatesListPresentation.ViewModel)
    func displayRefreshControl(response: NewProfile.RefreshControlUpdate.ViewModel)
}

final class NewProfileViewController: UIViewController, ControllerWithStepikPlaceholder {
    enum Animation {
        static let startRefreshDelay: TimeInterval = 1.0
        static let modulesRefreshDelay: TimeInterval = 0.3
    }

    private static let topBarAlphaStatusBarThreshold = 0.85

    fileprivate static let submodulesOrder: [NewProfile.Submodule] = [
        .streakNotifications, .createdCourses, .userActivity, .achievements, .certificates, .socialProfiles, .details
    ]

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var newProfileView: NewProfileView? { self.view as? NewProfileView }
    var styledNavigationController: StyledNavigationController? {
        self.navigationController as? StyledNavigationController
    }

    private let interactor: NewProfileInteractorProtocol
    private var state: NewProfile.ViewControllerState

    private let analytics: Analytics

    private var submodules: [Submodule] = []

    private lazy var settingsButton = UIBarButtonItem.stepikSettingsBarButtonItem(
        target: self,
        action: #selector(self.settingsButtonClicked)
    )
    private lazy var shareButton = UIBarButtonItem(
        barButtonSystemItem: .action,
        target: self,
        action: #selector(self.shareButtonClicked)
    )
    private lazy var profileEditButton = UIBarButtonItem(
        barButtonSystemItem: .compose,
        target: self,
        action: #selector(self.profileEditButtonClicked)
    )

    private var isStretchyHeaderAvailable = false
    private var lastKnownScrollOffset: CGFloat = 0

    init(
        interactor: NewProfileInteractorProtocol,
        initialState: NewProfile.ViewControllerState = .loading,
        analytics: Analytics
    ) {
        self.interactor = interactor
        self.state = initialState
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()

        self.updateState(newState: self.state)
        self.interactor.doProfileRefresh(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.interactor.doOnlineModeReset(request: .init())

        switch self.state {
        case .loading, .error:
            break
        case .anonymous:
            self.analytics.send(.profileScreenOpened(state: .anonymous))
        case .result(let data):
            self.analytics.send(.profileScreenOpened(state: data.isCurrentUserProfile ? .`self` : .other))
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateContentOffset(scrollOffset: self.lastKnownScrollOffset)
        }
    }

    // MARK: Private API

    private func setup() {
        self.styledNavigationController?.removeBackButtonTitleForTopController()
        self.updateContentInsets()
        self.registerPlaceholders()
    }

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .login,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    RoutingManager.auth.routeFrom(controller: strongSelf, success: nil, cancel: nil)
                }
            ),
            for: .anonymous
        )
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    self?.interactor.doProfileRefresh(request: .init(forceUpdate: true))
                }
            ),
            for: .connectionError
        )
    }

    @objc
    private func settingsButtonClicked() {
        self.analytics.send(.profileOpenSettingsTapped)

        let modalPresentationStyle = UIModalPresentationStyle.stepikAutomatic

        let assembly = SettingsAssembly(
            navigationBarAppearance: modalPresentationStyle.isSheetStyle ? .pageSheetAppearance() : .init(),
            moduleOutput: self.interactor as? SettingsOutputProtocol
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, embedInNavigation: false, modalPresentationStyle: modalPresentationStyle)
    }

    @objc
    private func shareButtonClicked() {
        self.interactor.doProfileShareAction(request: .init())
    }

    @objc
    private func profileEditButtonClicked() {
        self.interactor.doProfileEditAction(request: .init())
    }

    private func updateState(newState: NewProfile.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.isPlaceholderShown = false
            self.newProfileView?.showLoading()
            return
        }

        if case .loading = self.state {
            self.isPlaceholderShown = false
            self.newProfileView?.hideLoading()
        }

        self.newProfileView?.endRefreshing()

        switch newState {
        case .loading:
            break
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .anonymous:
            self.showPlaceholder(for: .anonymous)
        case .result(let viewModel):
            if self.title?.isEmpty ?? true {
                if !viewModel.isOrganization {
                    self.title = NSLocalizedString("Profile", comment: "")
                } else if viewModel.headerViewModel.coverURL == nil {
                    self.title = NSLocalizedString("Organization", comment: "")
                }
            }

            self.isPlaceholderShown = false
            self.newProfileView?.configure(viewModel: viewModel)

            if !self.isStretchyHeaderAvailable {
                self.isStretchyHeaderAvailable = viewModel.headerViewModel.isStretchyHeaderAvailable
            }
            self.updateContentOffset(scrollOffset: self.lastKnownScrollOffset)
            self.updateContentInsets()

            self.refreshCreatedCoursesState(.visible(teacherID: viewModel.userID))

            let shouldShowStreakNotifications = viewModel.isCurrentUserProfile
            self.refreshStreakNotificationsState(shouldShowStreakNotifications ? .visible : .hidden)

            let shouldShowUserActivity = !viewModel.isOrganization
            self.refreshUserActivityState(shouldShowUserActivity ? .visible : .hidden)

            let shouldShowAchievements = !viewModel.isOrganization
            self.refreshAchievementsState(shouldShowAchievements ? .visible : .hidden)

            let shouldShowCertificates = !viewModel.isOrganization
            self.refreshCertificatesState(shouldShowCertificates ? .visible : .hidden)

            let shouldShowSocialProfiles = viewModel.isOrganization && viewModel.socialProfilesCount > 0
            self.refreshSocialProfilesState(shouldShowSocialProfiles ? .visible : .hidden)

            self.refreshProfileDetailsState(viewModel: viewModel)
        }
    }

    private func getTopBarHeight() -> CGFloat {
        let navigationBarHeight = self.navigationController?.navigationBar.bounds.height
        let statusBarHeight = min(
            UIApplication.shared.statusBarFrame.size.width,
            UIApplication.shared.statusBarFrame.size.height
        )
        return (navigationBarHeight ?? 0) + statusBarHeight
    }

    private func updateContentOffset(scrollOffset: CGFloat) {
        guard self.isStretchyHeaderAvailable else {
            return
        }

        if scrollOffset > 0 {
            self.title = NSLocalizedString("Organization", comment: "")

            let topPadding = self.getTopBarHeight()
            let scrollingProgress = min(1, scrollOffset / topPadding)

            self.updateTopBar(alpha: scrollingProgress)
        } else {
            self.updateTopBar(alpha: 0)
        }
    }

    private func updateContentInsets() {
        let contentInsets = self.isStretchyHeaderAvailable
            ? .zero
            : UIEdgeInsets(top: self.getTopBarHeight(), left: 0, bottom: 0, right: 0)
        self.newProfileView?.contentInsets = contentInsets
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
                if alpha > CGFloat(Self.topBarAlphaStatusBarThreshold) {
                    return self.view.isDarkInterfaceStyle ? .lightContent : .dark
                } else {
                    return .lightContent
                }
            }()

            self.styledNavigationController?.changeStatusBarStyle(statusBarStyle, sender: self)
            self.styledNavigationController?.changeShadowViewAlpha(alpha, sender: self)
        }
    }

    // MARK: - Submodules

    private func registerSubmodule(_ submodule: Submodule) {
        self.submodules.append(submodule)

        if let viewController = submodule.viewController {
            self.addChild(viewController)
        }

        guard let insertingSubmoduleView = submodule.view else {
            return print("NewProfileViewController :: failed insert submodule view")
        }

        // Subviews has same position as in corresponding Submodule object
        for module in self.submodules where module.type.position >= submodule.type.position {
            if let nextSubmoduleView = module.view {
                self.newProfileView?.insertBlockView(insertingSubmoduleView, before: nextSubmoduleView)
            }
            return
        }
    }

    private func removeSubmodule(_ submodule: Submodule) {
        if let submoduleView = submodule.view {
            self.newProfileView?.removeBlockView(submoduleView)
        }
        submodule.viewController?.removeFromParent()
        self.submodules = self.submodules.filter { submodule.view != $0.view }
    }

    private func getSubmodule(type: SubmoduleType) -> Submodule? {
        self.submodules.first(where: { $0.type.uniqueIdentifier == type.uniqueIdentifier })
    }

    // MARK: Streak Notifications

    private enum StreakNotificationsState {
        case visible
        case hidden
    }

    private func refreshStreakNotificationsState(_ state: StreakNotificationsState) {
        switch state {
        case .visible:
            guard self.getSubmodule(type: NewProfile.Submodule.streakNotifications) == nil else {
                return
            }

            let assembly = NewProfileStreakNotificationsAssembly()
            let viewController = assembly.makeModule()

            self.registerSubmodule(
                .init(
                    viewController: viewController,
                    view: viewController.view,
                    type: NewProfile.Submodule.streakNotifications
                )
            )

            if let moduleInput = assembly.moduleInput {
                self.interactor.doSubmodulesRegistration(
                    request: .init(submodules: [NewProfile.Submodule.streakNotifications.uniqueIdentifier: moduleInput])
                )
            }
        case .hidden:
            if let submodule = self.getSubmodule(type: NewProfile.Submodule.streakNotifications) {
                self.removeSubmodule(submodule)
            }
        }
    }

    // MARK: Created Courses

    private enum CreatedCoursesState {
        case visible(teacherID: User.IdType)
        case hidden
    }

    private func refreshCreatedCoursesState(_ state: CreatedCoursesState) {
        switch state {
        case .visible(let teacherID):
            guard self.getSubmodule(type: NewProfile.Submodule.createdCourses) == nil else {
                return
            }

            let assembly = NewProfileCreatedCoursesAssembly(
                output: self.interactor as? NewProfileCreatedCoursesOutputProtocol
            )
            let viewController = assembly.makeModule()

            let headerView = NewProfileBlockHeaderView()
            headerView.titleText = NSLocalizedString("NewProfileBlockTitleCreatedCourses", comment: "")
            headerView.onShowAllButtonClick = { [weak self] in
                let assembly = FullscreenCourseListAssembly(courseListType: TeacherCourseListType(teacherID: teacherID))
                self?.push(module: assembly.makeModule())
            }

            let appearance = NewProfileBlockContainerView.Appearance(
                backgroundColor: .clear,
                contentViewInsets: .zero
            )
            let containerView = NewProfileBlockContainerView(
                headerView: headerView,
                contentView: viewController.view,
                appearance: appearance
            )

            self.registerSubmodule(
                .init(
                    viewController: viewController,
                    view: containerView,
                    type: NewProfile.Submodule.createdCourses
                )
            )

            if let moduleInput = assembly.moduleInput {
                self.interactor.doSubmodulesRegistration(
                    request: .init(submodules: [NewProfile.Submodule.createdCourses.uniqueIdentifier: moduleInput])
                )
            }
        case .hidden:
            if let submodule = self.getSubmodule(type: NewProfile.Submodule.createdCourses) {
                self.removeSubmodule(submodule)
            }
        }
    }

    // MARK: User Activity

    private enum UserActivityState {
        case visible
        case hidden
    }

    private func refreshUserActivityState(_ state: UserActivityState) {
        switch state {
        case .visible:
            guard self.getSubmodule(type: NewProfile.Submodule.userActivity) == nil else {
                return
            }

            let assembly = NewProfileUserActivityAssembly()
            let viewController = assembly.makeModule()

            let headerView = NewProfileBlockHeaderView()
            headerView.titleText = NSLocalizedString("NewProfileBlockTitleActivity", comment: "")
            headerView.isShowAllButtonHidden = true
            headerView.isUserInteractionEnabled = false

            let containerView = NewProfileBlockContainerView(
                headerView: headerView,
                contentView: viewController.view
            )

            self.registerSubmodule(
                .init(
                    viewController: viewController,
                    view: containerView,
                    type: NewProfile.Submodule.userActivity
                )
            )

            if let moduleInput = assembly.moduleInput {
                self.interactor.doSubmodulesRegistration(
                    request: .init(submodules: [NewProfile.Submodule.userActivity.uniqueIdentifier: moduleInput])
                )
            }
        case .hidden:
            if let submodule = self.getSubmodule(type: NewProfile.Submodule.userActivity) {
                self.removeSubmodule(submodule)
            }
        }
    }

    // MARK: Achievements

    private enum AchievementsState {
        case visible
        case hidden
    }

    private func refreshAchievementsState(_ state: AchievementsState) {
        switch state {
        case .visible:
            guard self.getSubmodule(type: NewProfile.Submodule.achievements) == nil else {
                return
            }

            let assembly = NewProfileAchievementsAssembly()
            let viewController = assembly.makeModule()

            let headerView = NewProfileBlockHeaderView()
            headerView.titleText = NSLocalizedString("NewProfileBlockTitleAchievements", comment: "")
            headerView.onShowAllButtonClick = { [weak self] in
                self?.interactor.doAchievementsListPresentation(request: .init())
            }

            let containerView = NewProfileBlockContainerView(
                headerView: headerView,
                contentView: viewController.view
            )

            self.registerSubmodule(
                .init(
                    viewController: viewController,
                    view: containerView,
                    type: NewProfile.Submodule.achievements
                )
            )

            if let moduleInput = assembly.moduleInput {
                self.interactor.doSubmodulesRegistration(
                    request: .init(submodules: [NewProfile.Submodule.achievements.uniqueIdentifier: moduleInput])
                )
            }
        case .hidden:
            if let submodule = self.getSubmodule(type: NewProfile.Submodule.achievements) {
                self.removeSubmodule(submodule)
            }
        }
    }

    // MARK: Certificates

    private enum CertificatesState {
        case visible
        case hidden
    }

    private func refreshCertificatesState(_ state: CertificatesState) {
        switch state {
        case .visible:
            guard self.getSubmodule(type: NewProfile.Submodule.certificates) == nil else {
                return
            }

            let assembly = NewProfileCertificatesAssembly(
                output: self.interactor as? NewProfileCertificatesOutputProtocol
            )
            let viewController = assembly.makeModule()

            let headerView = NewProfileBlockHeaderView()
            headerView.titleText = NSLocalizedString("NewProfileBlockTitleCertificates", comment: "")
            headerView.onShowAllButtonClick = { [weak self] in
                self?.interactor.doCertificatesListPresentation(request: .init())
            }

            let containerView = NewProfileBlockContainerView(
                headerView: headerView,
                contentView: viewController.view
            )

            self.registerSubmodule(
                .init(
                    viewController: viewController,
                    view: containerView,
                    type: NewProfile.Submodule.certificates
                )
            )

            if let moduleInput = assembly.moduleInput {
                self.interactor.doSubmodulesRegistration(
                    request: .init(submodules: [NewProfile.Submodule.certificates.uniqueIdentifier: moduleInput])
                )
            }
        case .hidden:
            if let submodule = self.getSubmodule(type: NewProfile.Submodule.certificates) {
                self.removeSubmodule(submodule)
            }
        }
    }

    // MARK: Social Profiles

    private enum SocialProfilesState {
        case visible
        case hidden
    }

    private func refreshSocialProfilesState(_ state: SocialProfilesState) {
        switch state {
        case .visible:
            guard self.getSubmodule(type: NewProfile.Submodule.socialProfiles) == nil else {
                return
            }

            let assembly = NewProfileSocialProfilesAssembly()
            let viewController = assembly.makeModule()

            let headerView = NewProfileBlockHeaderView()
            headerView.titleText = NSLocalizedString("NewProfileBlockTitleSocialProfiles", comment: "")
            headerView.isShowAllButtonHidden = true
            headerView.isUserInteractionEnabled = false

            var appearance = NewProfileBlockContainerView.Appearance()
            appearance.contentViewInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 0)
            let containerView = NewProfileBlockContainerView(
                headerView: headerView,
                contentView: viewController.view,
                appearance: appearance
            )

            self.registerSubmodule(
                .init(
                    viewController: viewController,
                    view: containerView,
                    type: NewProfile.Submodule.socialProfiles
                )
            )

            if let moduleInput = assembly.moduleInput {
                self.interactor.doSubmodulesRegistration(
                    request: .init(submodules: [NewProfile.Submodule.socialProfiles.uniqueIdentifier: moduleInput])
                )
            }
        case .hidden:
            if let submodule = self.getSubmodule(type: NewProfile.Submodule.socialProfiles) {
                self.removeSubmodule(submodule)
            }
        }
    }

    // MARK: Profile Details

    private func refreshProfileDetailsState(viewModel: NewProfileViewModel) {
        if let submodule = self.getSubmodule(type: NewProfile.Submodule.details),
           let profileDetailsViewController = submodule.viewController as? NewProfileDetailsViewController {
            profileDetailsViewController.newProfileDetailsView?.configure(
                viewModel: .init(
                    userID: viewModel.userID,
                    profileDetailsText: viewModel.userDetails,
                    isOrganization: viewModel.isOrganization
                )
            )
        } else {
            let profileDetailsAssembly = NewProfileDetailsAssembly()
            let profileDetailsViewController = profileDetailsAssembly.makeModule()

            let headerView = NewProfileBlockHeaderView()
            headerView.titleText = viewModel.isOrganization
                ? NSLocalizedString("NewProfileBlockTitleDetailsOrganization", comment: "")
                : NSLocalizedString("NewProfileBlockTitleDetails", comment: "")
            headerView.isShowAllButtonHidden = true
            headerView.isUserInteractionEnabled = false

            let containerView = NewProfileBlockContainerView(
                headerView: headerView,
                contentView: profileDetailsViewController.view,
                appearance: .init(contentViewInsets: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
            )

            self.registerSubmodule(
                .init(
                    viewController: profileDetailsViewController,
                    view: containerView,
                    type: NewProfile.Submodule.details
                )
            )

            if let moduleInput = profileDetailsAssembly.moduleInput {
                self.interactor.doSubmodulesRegistration(
                    request: .init(submodules: [NewProfile.Submodule.details.uniqueIdentifier: moduleInput])
                )
            }
        }
    }

    // MARK: Inner Types

    private final class Submodule {
        weak var viewController: UIViewController?
        weak var view: UIView?

        let type: SubmoduleType

        init(viewController: UIViewController?, view: UIView?, type: SubmoduleType) {
            self.viewController = viewController
            self.view = view
            self.type = type
        }
    }
}

// MARK: - NewProfileViewController: NewProfileViewDelegate -

extension NewProfileViewController: NewProfileViewDelegate {
    func newProfileView(_ view: NewProfileView, didScroll scrollView: UIScrollView) {
        self.lastKnownScrollOffset = scrollView.contentOffset.y
        self.updateContentOffset(scrollOffset: self.lastKnownScrollOffset)
    }

    func newProfileViewRefreshControlDidRefresh(_ view: NewProfileView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.startRefreshDelay) { [weak self] in
            self?.interactor.doProfileRefresh(request: .init(forceUpdate: true))
        }
    }
}

// MARK: - NewProfileViewController: NewProfileViewControllerProtocol -

extension NewProfileViewController: NewProfileViewControllerProtocol {
    func displayProfile(viewModel: NewProfile.ProfileLoad.ViewModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.modulesRefreshDelay) { [weak self] in
            self?.updateState(newState: viewModel.state)
        }
    }

    func displayNavigationControls(viewModel: NewProfile.NavigationControlsPresentation.ViewModel) {
        var leftBarButtonItems = [UIBarButtonItem]()
        var rightBarButtonItems = [UIBarButtonItem]()

        if viewModel.isSettingsAvailable {
            rightBarButtonItems.append(self.settingsButton)
        }
        if viewModel.isEditProfileAvailable {
            rightBarButtonItems.append(self.profileEditButton)
        }

        if viewModel.isShareProfileAvailable {
            if rightBarButtonItems.isEmpty {
                rightBarButtonItems.append(self.shareButton)
            } else {
                leftBarButtonItems.append(self.shareButton)
            }
        }

        self.navigationItem.leftBarButtonItems = leftBarButtonItems
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    func displaySubmoduleEmptyState(viewModel: NewProfile.SubmoduleEmptyStatePresentation.ViewModel) {
        switch viewModel.module {
        case .createdCourses:
            self.refreshCreatedCoursesState(.hidden)
        case .certificates:
            self.refreshCertificatesState(.hidden)
        default:
            assertionFailure("Unsupported module type")
        }
    }

    func displayAuthorization(viewModel: NewProfile.AuthorizationPresentation.ViewModel) {
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }

    func displayProfileSharing(viewModel: NewProfile.ProfileShareAction.ViewModel) {
        let sharingViewController = SharingHelper.getSharingController(viewModel.urlPath)
        sharingViewController.popoverPresentationController?.barButtonItem = self.shareButton
        self.present(module: sharingViewController)
    }

    func displayProfileEditing(viewModel: NewProfile.ProfileEditAction.ViewModel) {
        let modalPresentationStyle = UIModalPresentationStyle.stepikAutomatic

        let assembly = ProfileEditAssembly(
            profile: viewModel.profile,
            navigationBarAppearance: modalPresentationStyle.isSheetStyle ? .pageSheetAppearance() : .init()
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, embedInNavigation: false, modalPresentationStyle: modalPresentationStyle)
    }

    func displayAchievementsList(viewModel: NewProfile.AchievementsListPresentation.ViewModel) {
        let assembly = AchievementsListLegacyAssembly(userID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }

    func displayCertificatesList(viewModel: NewProfile.CertificatesListPresentation.ViewModel) {
        let assembly = CertificatesLegacyAssembly(userID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }

    func displayRefreshControl(response: NewProfile.RefreshControlUpdate.ViewModel) {
        if response.shouldEndRefreshing {
            self.newProfileView?.endRefreshing()
        }
    }
}

// MARK: - NewProfile.Submodule: SubmoduleType -

extension NewProfile.Submodule: SubmoduleType {
    var position: Int {
        guard let position = NewProfileViewController.submodulesOrder.firstIndex(of: self) else {
            fatalError("Given submodule type has unknown position")
        }
        return position
    }
}
