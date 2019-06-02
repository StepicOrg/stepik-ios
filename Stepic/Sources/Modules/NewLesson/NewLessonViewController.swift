import Pageboy
import SnapKit
import Tabman
import UIKit

protocol NewLessonViewControllerProtocol: class {
    func displayLesson(viewModel: NewLesson.LessonLoad.ViewModel)
    func displayLessonNavigation(viewModel: NewLesson.LessonNavigationLoad.ViewModel)
    func displayStepPassedStatusUpdate(viewModel: NewLesson.StepPassedStatusUpdate.ViewModel)
}

final class NewLessonViewController: TabmanViewController {
    private static let animationDuration: TimeInterval = 0.25

    enum Appearance {
        static let barTintColor = UIColor.mainDark
        static let backgroundColor = UIColor.mainLight
        static let indicatorHeight: CGFloat = 2
        static let separatorColor = UIColor.gray
        static let loadingIndicatorColor = UIColor.mainDark
    }

    private let interactor: NewLessonInteractorProtocol

    private lazy var infoBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "info-system"), style: .plain, target: self, action: nil)
        return item
    }()

    private lazy var shareBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(self.shareButtonClicked)
        )
        item.isEnabled = false
        return item
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicatorView.color = Appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    // Cause Tabman doesn't support controllers removing
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
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
                self.showLoading()
            case .result:
                self.showSteps()
            case .error:
                self.showError()
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

        self.addSubviews()

        self.navigationItem.rightBarButtonItems = [self.shareBarButtonItem]
        self.dataSource = self
    }

    // MARK: Private API

    private func addSubviews() {
        self.overlayView.addSubview(self.loadingIndicator)
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.view.insertSubview(self.overlayView, at: Int.max)
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func showSteps() {
        guard case .result(let data) = self.state else {
            return
        }

        self.title = data.lessonTitle
        self.shareBarButtonItem.isEnabled = true
        self.stepControllers = Array(repeating: nil, count: data.steps.count)
        self.stepModulesInputs = Array(repeating: nil, count: data.steps.count)

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.changeShadowViewAlpha(0.0, sender: self)
        }

        self.reloadData()
        self.addBar(self.tabBarView, dataSource: self, at: .top)

        UIView.animate(withDuration: NewLessonViewController.animationDuration) {
            self.overlayView.alpha = 0.0
        }
    }

    private func showError() {
        self.clearAll()
    }

    private func showLoading() {
        self.clearAll()
        self.overlayView.alpha = 1.0
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

    private func clearAll() {
        self.title = nil
        self.stepControllers.removeAll()
        self.stepModulesInputs.removeAll()
        self.shareBarButtonItem.isEnabled = false

        self.hasNavigationToPreviousUnit = false
        self.hasNavigationToNextUnit = false

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.changeShadowViewAlpha(1.0, sender: self)
        }
    }

    @objc
    private func shareButtonClicked() {
        guard case .result(let data) = self.state else {
            fatalError("Invalid state")
        }

        DispatchQueue.global().async {
            let link = data.stepLinkMaker("\((self.currentIndex ?? 0) + 1)")
            let sharingViewController = SharingHelper.getSharingController(link)
            sharingViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
            DispatchQueue.main.async {
                self.present(sharingViewController, animated: true, completion: nil)
            }
        }
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
        if case .result(let data) = self.state {
            return .at(index: data.startStepIndex)
        }
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

    func displayStepPassedStatusUpdate(viewModel: NewLesson.StepPassedStatusUpdate.ViewModel) {
        let tabIdentifier = "\(viewModel.stepID)"

        NotificationCenter.default.post(
            name: StepTabBarButton.didMarkAsDone,
            object: nil,
            userInfo: [StepTabBarButton.userInfoIDKey: tabIdentifier]
        )
    }
}
