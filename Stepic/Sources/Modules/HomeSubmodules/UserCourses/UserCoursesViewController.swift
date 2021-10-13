import Pageboy
import SnapKit
import Tabman
import UIKit

protocol UserCoursesViewControllerProtocol: AnyObject {
    func displayUserCourses(viewModel: UserCourses.UserCoursesLoad.ViewModel)
}

final class UserCoursesViewController: TabmanViewController {
    enum Appearance {
        static let backgroundColor = UIColor.stepikBackground

        static let barTintColor = UIColor.stepikAccent
        static let barBackgroundColor = UIColor.stepikNavigationBarBackground
        static let barSeparatorColor = UIColor.stepikOpaqueSeparator
        static let barInterButtonSpacing: CGFloat = 16
        static let barContentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        static var navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState {
            .init(shadowViewAlpha: 0.0)
        }
    }

    private lazy var tabBarView: TMBar = {
        let bar = TMBarView<TMHorizontalBarLayout, StepikLabelBarButton, TMLineBarIndicator>()
        bar.layout.transitionStyle = .snap
        bar.tintColor = Appearance.barTintColor
        bar.backgroundView.style = .flat(color: Appearance.barBackgroundColor)
        bar.indicator.tintColor = Appearance.barTintColor
        bar.indicator.weight = .light
        bar.layout.interButtonSpacing = Appearance.barInterButtonSpacing
        bar.layout.contentInset = Appearance.barContentInset
        bar.layout.alignment = .leading
        bar.layout.contentMode = .intrinsic

        let separatorView = UIView()
        separatorView.backgroundColor = Appearance.barSeparatorColor
        bar.backgroundView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1.0 / UIScreen.main.nativeScale)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return bar
    }()

    private let interactor: UserCoursesInteractorProtocol

    private let availableTabs: [UserCourses.Tab]
    private let initialTabIndex: Int
    private var tabViewControllers: [UIViewController?] = []

    private let analytics: Analytics

    init(
        interactor: UserCoursesInteractorProtocol,
        availableTabs: [UserCourses.Tab],
        initialTab: UserCourses.Tab,
        analytics: Analytics
    ) {
        self.interactor = interactor

        self.availableTabs = availableTabs
        self.tabViewControllers = Array(repeating: nil, count: availableTabs.count)

        if let initialTabIndex = self.availableTabs.firstIndex(of: initialTab) {
            self.initialTabIndex = initialTabIndex
        } else {
            self.initialTabIndex = 0
        }

        self.analytics = analytics

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UserCoursesView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.interactor.doUserCoursesFetch(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.styledNavigationController?.changeShadowViewAlpha(
            Appearance.navigationBarAppearance.shadowViewAlpha,
            sender: self
        )

        self.analytics.send(.myCoursesScreenOpened)
    }

    override func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: TabmanViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {
        super.pageboyViewController(
            pageboyViewController,
            didScrollToPageAt: index,
            direction: direction,
            animated: animated
        )

        if let selectedTab = self.availableTabs[safe: index] {
            self.analytics.send(.myCoursesScreenTabOpened(tab: selectedTab))
        }
    }

    // MARK: Private API

    private func setup() {
        self.title = NSLocalizedString("UserCoursesTitle", comment: "")
        self.view.backgroundColor = Appearance.backgroundColor

        self.dataSource = self
        self.addBar(self.tabBarView, dataSource: self, at: .top)
    }

    private func loadTabViewControllerIfNeeded(at index: Int) {
        guard self.tabViewControllers.count > index else {
            fatalError("Invalid controllers initialization")
        }

        guard self.tabViewControllers[index] == nil else {
            return
        }

        guard let tab = self.availableTabs[safe: index] else {
            return
        }

        let assembly = FullscreenCourseListAssembly(
            presentationDescription: nil,
            courseListType: tab.courseListType,
            courseViewSource: .myCourses
        )

        self.tabViewControllers[index] = assembly.makeModule()
    }
}

private extension UserCourses.Tab {
    var courseListType: CourseListType {
        switch self {
        case .allCourses:
            return EnrolledCourseListType()
        case .favorites:
            return FavoriteCourseListType()
        case .downloaded:
            return DownloadedCourseListType()
        case .archived:
            return ArchivedCourseListType()
        }
    }
}

// MARK: - UserCoursesViewController: UserCoursesViewControllerProtocol -

extension UserCoursesViewController: UserCoursesViewControllerProtocol {
    func displayUserCourses(viewModel: UserCourses.UserCoursesLoad.ViewModel) {
        self.reloadData()
    }
}

// MARK: - UserCoursesViewController: PageboyViewControllerDataSource -

extension UserCoursesViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        self.availableTabs.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        self.loadTabViewControllerIfNeeded(at: index)
        return self.tabViewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        .at(index: self.initialTabIndex)
    }
}

// MARK: - UserCoursesViewController: TMBarDataSource -

extension UserCoursesViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = self.availableTabs[safe: index]?.title ?? ""
        return TMBarItem(title: title)
    }
}

// MARK: - UserCoursesViewController: StyledNavigationControllerPresentable -

extension UserCoursesViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        Appearance.navigationBarAppearance
    }
}
