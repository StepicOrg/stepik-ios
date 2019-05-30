import Pageboy
import SnapKit
import Tabman
import UIKit

protocol NewLessonViewControllerProtocol: class {
    func displayLesson(viewModel: NewLesson.LessonLoad.ViewModel)
    func displayLessonNavigation(viewModel: NewLesson.LessonNavigationLoad.ViewModel)
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
    private var stepModulesInputs: [NewStepInputProtocol?] = []

    private var hasNavigationToPreviousUnit = false
    private var hasNavigationToNextUnit = false

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
        self.stepModulesInputs = Array(repeating: nil, count: data.steps.count)

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

        let assembly = NewStepAssembly(stepID: step.id, output: self.interactor as? NewStepOutputProtocol)
        let controller = assembly.makeModule()
        self.stepControllers[index] = controller
        self.stepModulesInputs[index] = assembly.moduleInput
        return controller
    }

    private func updateLessonNavigationInStep(
        index: Int,
        hasNavigationToPreviousUnit: Bool,
        hasNavigationToNextUnit: Bool
    ) {
        // Can navigate to previous unit from current step
        let canNavigateToPreviousUnit = index == 0 && hasNavigationToPreviousUnit
        let canNavigateToNextUnit = (index == self.stepModulesInputs.count - 1) && hasNavigationToNextUnit

        guard let input = self.stepModulesInputs[safe: index].flatMap({ $0 }) else {
            return
        }

        input.updateStepNavigation(
            canNavigateToPreviousUnit: canNavigateToPreviousUnit,
            canNavigateNextUnit: canNavigateToNextUnit
        )
    }

    private func updateLessonNavigationInSteps(hasNavigationToPreviousUnit: Bool, hasNavigationToNextUnit: Bool) {
        for index in 0..<self.stepModulesInputs.count {
            self.updateLessonNavigationInStep(
                index: index,
                hasNavigationToPreviousUnit: hasNavigationToPreviousUnit,
                hasNavigationToNextUnit: hasNavigationToNextUnit
            )
        }
    }

    private func resetState() {
        self.title = nil
        self.stepControllers.removeAll()
        self.stepModulesInputs.removeAll()

        self.hasNavigationToPreviousUnit = false
        self.hasNavigationToNextUnit = false
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
        self.updateLessonNavigationInStep(
            index: index,
            hasNavigationToPreviousUnit: self.hasNavigationToPreviousUnit,
            hasNavigationToNextUnit: self.hasNavigationToNextUnit
        )
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

        let stepStringID = "\(stepDescription.id)"
        // Pass random badgeValue to mark step as passed
        let badgeValue = stepDescription.isPassed ? "+" : nil
        return TMBarItem(title: stepStringID, image: stepDescription.iconImage, badgeValue: badgeValue)
    }
}

extension NewLessonViewController: NewLessonViewControllerProtocol {
    func displayLesson(viewModel: NewLesson.LessonLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayLessonNavigation(viewModel: NewLesson.LessonNavigationLoad.ViewModel) {
        self.hasNavigationToNextUnit = viewModel.hasNextUnit
        self.hasNavigationToPreviousUnit = viewModel.hasPreviousUnit

        self.updateLessonNavigationInSteps(
            hasNavigationToPreviousUnit: self.hasNavigationToPreviousUnit,
            hasNavigationToNextUnit: self.hasNavigationToNextUnit
        )
    }
}
