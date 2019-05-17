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

    private var stepControllers: [UIViewController?] = []

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

    private var state: NewLesson.ViewControllerState {
        didSet {
            switch self.state {
            case .loading:
                self.hideSteps()
            case .result:
                self.showSteps()
            default:
                break
            }
        }
    }

    init(interactor: NewLessonInteractorProtocol) {
        self.interactor = interactor
        self.state = .loading
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.removeBackButtonTitleForTopController()
            styledNavigationController.changeShadowViewAlpha(1.0, sender: self)
        }

        self.navigationItem.rightBarButtonItems = [self.shareBarButtonItem]
    }

    // MARK: Private API

    private func showSteps() {
        guard case .result(let data) = self.state else {
            return
        }

        self.title = data.lessonTitle
        self.stepControllers = Array(repeating: nil, count: data.steps.count)

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
    }

    private func loadStepIfNeeded(index: Int) -> UIViewController {
        guard self.stepControllers.count > index else {
            fatalError("Invalid controllers initialization")
        }

        guard case .result(let data) = self.state, let step = data.steps[safe: index] else {
            fatalError("Invalid state")
        }

        if let controller = self.stepControllers[index] {
            return controller
        }

        let assembly = NewStepAssembly(stepID: step.id)
        let controller = assembly.makeModule()
        self.stepControllers[index] = controller
        return controller
    }
}

extension NewLessonViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        if case .result(let data) = self.state {
            return data.steps.count
        }
        return 0
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        let controller = self.loadStepIfNeeded(index: index)
        return controller
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

extension NewLessonViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        guard case .result(let data) = self.state, let stepDescription = data.steps[safe: index] else {
            fatalError("Step not found")
        }

        return TMBarItem(image: stepDescription.iconImage)
    }
}

extension NewLessonViewController: NewLessonViewControllerProtocol {
    func displayLesson(viewModel: NewLesson.LessonLoad.ViewModel) {
        self.state = viewModel.state
    }
}
