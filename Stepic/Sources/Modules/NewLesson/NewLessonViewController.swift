import Pageboy
import SnapKit
import Tabman
import UIKit

protocol NewLessonViewControllerProtocol: class {
    func displayLesson(viewModel: NewLesson.LessonLoad.ViewModel)
}

final class NewLessonViewController: TabmanViewController {
    enum Appearance {
        static let barTintColor = UIColor.mainDark
        static let backgroundColor = UIColor.mainLight
        static let indicatorHeight: CGFloat = 2
        static let separatorColor = UIColor.gray
    }

    lazy var newLessonView = self.view as? NewLessonView

    private let interactor: NewLessonInteractorProtocol

    private lazy var infoBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "info-system"), style: .plain, target: self, action: nil)
        return item
    }()

    private lazy var shareBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: nil)
        return item
    }()

    private lazy var tooltipView = LessonInfoTooltipView()

    private lazy var tabBarView: TMBar = {
        let bar = TMBarView<TMHorizontalBarLayout, StepTabBarButton, TMLineBarIndicator>()
        bar.layout.transitionStyle = .snap
        bar.tintColor = Appearance.barTintColor
        bar.backgroundView.style = .flat(color: Appearance.backgroundColor)
        bar.indicator.tintColor = Appearance.barTintColor
        bar.indicator.weight = .custom(value: 2)
        bar.layout.interButtonSpacing = 0

        let separatorView = UIView()
        separatorView.backgroundColor = Appearance.separatorColor
        bar.backgroundView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1.0 / UIScreen.main.nativeScale)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return bar
    }()

    private var currentState: NewLesson.ViewControllerState {
        didSet {
            switch self.currentState {
            case .loading:
                self.hideSteps()
            case .result(let data):
                self.showSteps()
            default:
                break
            }
        }
    }

    init(interactor: NewLessonInteractorProtocol) {
        self.interactor = interactor
        self.currentState = .loading
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = NewLessonView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.removeBackButtonTitleForTopController()
            styledNavigationController.changeShadowViewAlpha(1.0, sender: self)
        }

        self.edgesForExtendedLayout = []
        self.navigationItem.rightBarButtonItems = [self.shareBarButtonItem]
    }

    // MARK: Private API

    private func showSteps() {
        guard case .result(let data) = self.currentState else {
            return
        }

        self.title = data.lessonTitle
        self.newLessonView?.hideLoading()

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.changeShadowViewAlpha(0.0, sender: self)
        }

        self.dataSource = self
        self.addBar(self.tabBarView, dataSource: self, at: .top)
    }

    private func hideSteps() {
        self.title = nil
        self.dataSource = nil
        self.reloadData()

        self.newLessonView?.showLoading()
    }
}

extension NewLessonViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        if case .result(let data) = self.currentState {
            return data.steps.count
        }
        return 0
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

extension NewLessonViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        guard case .result(let data) = self.currentState, let stepDescription = data.steps[safe: index] else {
            fatalError("Step not found")
        }

        return TMBarItem(image: stepDescription.iconImage)
    }
}

extension NewLessonViewController: NewLessonViewControllerProtocol {
    func displayLesson(viewModel: NewLesson.LessonLoad.ViewModel) {
        self.currentState = viewModel.state
    }
}
