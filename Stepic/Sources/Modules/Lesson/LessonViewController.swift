import EasyTipView
import Pageboy
import SnapKit
import SVProgressHUD
import Tabman
import UIKit

// swiftlint:disable file_length
protocol LessonViewControllerProtocol: AnyObject {
    func displayLesson(viewModel: LessonDataFlow.LessonLoad.ViewModel)
    func displayLessonNavigation(viewModel: LessonDataFlow.LessonNavigationLoad.ViewModel)
    func displayLessonTooltipInfo(viewModel: LessonDataFlow.LessonTooltipInfoLoad.ViewModel)
    func displayLessonModule(viewModel: LessonDataFlow.LessonModulePresentation.ViewModel)
    func displayStepTooltipInfoUpdate(viewModel: LessonDataFlow.StepTooltipInfoUpdate.ViewModel)
    func displayStepPassedStatusUpdate(viewModel: LessonDataFlow.StepPassedStatusUpdate.ViewModel)
    func displayCurrentStepUpdate(viewModel: LessonDataFlow.CurrentStepUpdate.ViewModel)
    func displayCurrentStepAutoplay(viewModel: LessonDataFlow.CurrentStepAutoplay.ViewModel)
    func displayEditStep(viewModel: LessonDataFlow.EditStepPresentation.ViewModel)
    func displaySubmissions(viewModel: LessonDataFlow.SubmissionsPresentation.ViewModel)
    func displayStepTextUpdate(viewModel: LessonDataFlow.StepTextUpdate.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: LessonDataFlow.BlockingWaitingIndicatorUpdate.ViewModel)
    func displayUnitNavigationExamState(viewModel: LessonDataFlow.UnitNavigationExamPresentation.ViewModel)
    func displayUnitNavigationUnreachableState(
        viewModel: LessonDataFlow.UnitNavigationUnreachablePresentation.ViewModel
    )
    func displayUnitNavigationRequirementNotSatisfiedState(
        viewModel: LessonDataFlow.UnitNavigationRequirementNotSatisfiedPresentation.ViewModel
    )
    func displayUnitNavigationClosedByDateState(
        viewModel: LessonDataFlow.UnitNavigationClosedByDatePresentation.ViewModel
    )
    func displayUnitNavigationFinishedDemoAccessState(
        viewModel: LessonDataFlow.UnitNavigationFinishedDemoAccessPresentation.ViewModel
    )
    func displayLessonFinishedSteps(viewModel: LessonDataFlow.LessonFinishedStepsPresentation.ViewModel)
}

// MARK: - LessonViewController: TabmanViewController, ControllerWithStepikPlaceholder -

final class LessonViewController: TabmanViewController, ControllerWithStepikPlaceholder {
    private static let animationDuration: TimeInterval = 0.25

    enum Appearance {
        static let barTintColor = UIColor.stepikAccent
        static let barBackgroundColor = UIColor.stepikNavigationBarBackground
        static let backgroundColor = UIColor.stepikBackground
        static let indicatorHeight: CGFloat = 2
        static let separatorColor = UIColor.stepikOpaqueSeparator
        static let loadingIndicatorColor = UIColor.stepikLoadingIndicator
        static let tooltipBackgroundColor = UIColor.dynamic(light: .stepikAccent, dark: .stepikAlertBackground)
        static let tooltipContentInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    private let interactor: LessonInteractorProtocol
    private let deepLinkRoutingService: DeepLinkRoutingService

    private lazy var infoBarButtonItem = UIBarButtonItem.stepikInfoBarButtonItem(
        target: self,
        action: #selector(self.infoButtonClicked)
    )
    private lazy var moreBarButtonItem = UIBarButtonItem.stepikMoreBarButtonItem(
        target: self,
        action: #selector(self.moreButtonClicked)
    )

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikWhiteLarge)
        loadingIndicatorView.color = Appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    // Cause Tabman doesn't support controllers removing
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.backgroundColor
        return view
    }()

    private var tooltipView: EasyTipView?
    private var isTooltipVisible = false
    private var tooltipInfos: [Step.IdType: [LessonDataFlow.TooltipInfo]] = [:]

    private var stepControllers: [UIViewController?] = []
    private var stepModulesInputs: [StepInputProtocol?] = []

    private var hasNavigationToPreviousUnit = false
    private var hasNavigationToNextUnit = false

    private lazy var tabBarView: TMBar = {
        let bar = TMBarView<TMHorizontalBarLayout, StepTabBarButton, TMLineBarIndicator>()
        bar.layout.transitionStyle = .snap
        bar.tintColor = Appearance.barTintColor
        bar.backgroundView.style = .flat(color: Appearance.barBackgroundColor)
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

    private var state: LessonDataFlow.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    var placeholderContainer = StepikPlaceholderControllerContainer()

    init(interactor: LessonInteractorProtocol, deepLinkRoutingService: DeepLinkRoutingService) {
        self.interactor = interactor
        self.deepLinkRoutingService = deepLinkRoutingService
        self.state = .loading
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnectionQuiz,
                action: { [weak self] in
                    self?.state = .loading
                    self?.interactor.doLessonLoad(request: .init())
                }
            ),
            for: .connectionError
        )

        self.view.backgroundColor = Appearance.backgroundColor

        self.navigationItem.rightBarButtonItems = [self.moreBarButtonItem, self.infoBarButtonItem]
        self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }

        self.styledNavigationController?.removeBackButtonTitleForTopController()
        self.styledNavigationController?.changeShadowViewAlpha(1.0, sender: self)

        self.addSubviews()
        self.dataSource = self

        self.updateState()
        self.interactor.doLessonLoad(request: .init())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tooltipView?.dismiss()
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
        self.updateInfoBarButtonItem()
    }

    // MARK: Private API

    private func updateState() {
        switch self.state {
        case .loading:
            self.showLoading()
        case .result:
            self.showSteps()
        case .error:
            self.showError()
        }
    }

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

        self.isPlaceholderShown = false

        self.title = data.lessonTitle
        self.moreBarButtonItem.isEnabled = true
        self.stepControllers = Array(repeating: nil, count: data.steps.count)
        self.stepModulesInputs = Array(repeating: nil, count: data.steps.count)

        self.styledNavigationController?.changeShadowViewAlpha(0.0, sender: self)

        self.reloadData()

        if self.tabBarView.superview == nil {
            self.addBar(self.tabBarView, dataSource: self, at: .top)
        }

        UIView.animate(withDuration: Self.animationDuration) {
            self.overlayView.alpha = 0.0
        }
    }

    private func showError() {
        self.clearAll()
        self.showPlaceholder(for: .connectionError)
    }

    private func showLoading() {
        self.clearAll()
        self.isPlaceholderShown = false
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

        let assembly = StepAssembly(stepID: step.id, output: self.interactor as? StepOutputProtocol)
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
        let canNavigateToNextStep = index != self.stepModulesInputs.count - 1

        guard let input = self.stepModulesInputs[safe: index].flatMap({ $0 }) else {
            return
        }

        input.updateStepNavigation(
            canNavigateToPreviousUnit: canNavigateToPreviousUnit,
            canNavigateToNextUnit: canNavigateToNextUnit,
            canNavigateToNextStep: canNavigateToNextStep
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
        self.tooltipInfos.removeAll()
        self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }

        self.hasNavigationToPreviousUnit = false
        self.hasNavigationToNextUnit = false

        self.styledNavigationController?.changeShadowViewAlpha(1.0, sender: self)
    }

    private func updateInfoBarButtonItem() {
        let isEnabled: Bool = {
            guard case .result(let data) = self.state,
                  let currentIndex = self.currentIndex,
                  let step = data.steps[safe: currentIndex],
                  let info = self.tooltipInfos[step.id] else {
                return false
            }
            return !info.isEmpty
        }()
        self.infoBarButtonItem.isEnabled = isEnabled
    }

    // MARK: Actions

    @objc
    private func infoButtonClicked() {
        guard case .result(let data) = self.state else {
            fatalError("Invalid state")
        }

        guard let currentIndex = self.currentIndex,
              let step = data.steps[safe: currentIndex],
              let tooltipInfo = self.tooltipInfos[step.id] else {
            return
        }

        if self.isTooltipVisible {
            self.tooltipView?.dismiss()
        } else {
            // TODO: Refactor add support for custom content views to the `Tooltip`.
            let contentView = LessonInfoTooltipView()
            contentView.configure(viewModel: tooltipInfo.map { .init(icon: $0.iconImage, text: $0.text) })
            contentView.sizeToFit()

            var preferences = EasyTipView.Preferences()
            preferences.drawing.backgroundColor = Appearance.tooltipBackgroundColor
            preferences.drawing.arrowPosition = .top
            preferences.positioning.contentInsets = Appearance.tooltipContentInsets

            self.tooltipView = EasyTipView(contentView: contentView, preferences: preferences, delegate: self)
            self.tooltipView?.show(
                animated: true,
                forItem: self.infoBarButtonItem,
                withinSuperView: self.navigationController?.view
            )

            self.isTooltipVisible = true
        }
    }

    @objc
    private func moreButtonClicked() {
        guard case .result(let data) = self.state,
              let currentIndex = self.currentIndex,
              let step = data.steps[safe: currentIndex] else {
            return
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Share", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.presentShareStep()
                }
            )
        )

        if step.isQuiz {
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("StepSubmissionsAlertActionTitle", comment: ""),
                    style: .default,
                    handler: { [weak self] _ in
                        self?.interactor.doSubmissionsPresentation(request: .init(index: currentIndex))
                    }
                )
            )
        }

        if step.canEdit {
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("EditStepAlertActionTitle", comment: ""),
                    style: .default,
                    handler: { [weak self] _ in
                        guard let strongSelf = self else {
                            return
                        }

                        strongSelf.interactor.doEditStepPresentation(request: .init(index: currentIndex))
                    }
                )
            )
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.popoverPresentationController?.barButtonItem = self.moreBarButtonItem

        self.present(alert, animated: true, completion: nil)
    }

    private func presentShareStep() {
        guard case .result(let data) = self.state,
              let stepURL = data.stepLinkMaker((self.currentIndex ?? 0) + 1) else {
            return
        }

        DispatchQueue.global().async {
            let sharingViewController = SharingHelper.getSharingController(stepURL.absoluteString)
            DispatchQueue.main.async {
                sharingViewController.popoverPresentationController?.barButtonItem = self.moreBarButtonItem
                self.present(sharingViewController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - LessonViewController: PageboyViewControllerDataSource -

extension LessonViewController: PageboyViewControllerDataSource {
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
        guard 0..<self.stepControllers.count ~= index else {
            return nil
        }

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

// MARK: - LessonViewController: TMBarDataSource -

extension LessonViewController: TMBarDataSource {
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

// MARK: - LessonViewController: LessonViewControllerProtocol -

extension LessonViewController: LessonViewControllerProtocol {
    func displayLesson(viewModel: LessonDataFlow.LessonLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayLessonNavigation(viewModel: LessonDataFlow.LessonNavigationLoad.ViewModel) {
        self.hasNavigationToNextUnit = viewModel.hasNextUnit
        self.hasNavigationToPreviousUnit = viewModel.hasPreviousUnit

        self.updateLessonNavigationInSteps(
            hasNavigationToPreviousUnit: self.hasNavigationToPreviousUnit,
            hasNavigationToNextUnit: self.hasNavigationToNextUnit
        )
    }

    func displayLessonTooltipInfo(viewModel: LessonDataFlow.LessonTooltipInfoLoad.ViewModel) {
        self.tooltipInfos = viewModel.data
        self.updateInfoBarButtonItem()
    }

    func displayLessonModule(viewModel: LessonDataFlow.LessonModulePresentation.ViewModel) {
        self.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: false))

        self.deepLinkRoutingService
            .route(.lesson(lessonID: viewModel.lessonID, stepID: viewModel.stepIndex, unitID: nil))
            .done { _ in
                SVProgressHUD.showSuccess(withStatus: nil)
            }.catch { _ in
                self.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: true))
            }
    }

    func displayStepTooltipInfoUpdate(viewModel: LessonDataFlow.StepTooltipInfoUpdate.ViewModel) {
        self.tooltipInfos[viewModel.stepID] = viewModel.info
        self.updateInfoBarButtonItem()
    }

    func displayStepPassedStatusUpdate(viewModel: LessonDataFlow.StepPassedStatusUpdate.ViewModel) {
        let tabIdentifier = "\(viewModel.stepID)"

        NotificationCenter.default.post(
            name: StepTabBarButton.didMarkAsDone,
            object: nil,
            userInfo: [StepTabBarButton.userInfoIDKey: tabIdentifier]
        )
    }

    func displayCurrentStepUpdate(viewModel: LessonDataFlow.CurrentStepUpdate.ViewModel) {
        self.scrollToPage(.at(index: viewModel.index), animated: true)
    }

    func displayCurrentStepAutoplay(viewModel: LessonDataFlow.CurrentStepAutoplay.ViewModel) {
        guard let currentIndex = self.currentIndex,
              let stepModuleInput = self.stepModulesInputs[safe: currentIndex] else {
            return
        }

        stepModuleInput?.autoplayStep()
    }

    func displayEditStep(viewModel: LessonDataFlow.EditStepPresentation.ViewModel) {
        let modalPresentationStyle = UIModalPresentationStyle.stepikAutomatic

        let assembly = EditStepAssembly(
            stepID: viewModel.stepID,
            navigationBarAppearance: modalPresentationStyle.isSheetStyle ? .pageSheetAppearance() : .init(),
            output: self.interactor as? EditStepOutputProtocol
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, embedInNavigation: false, modalPresentationStyle: modalPresentationStyle)
    }

    func displaySubmissions(viewModel: LessonDataFlow.SubmissionsPresentation.ViewModel) {
        let modalPresentationStyle = UIModalPresentationStyle.stepikAutomatic

        let assembly = SubmissionsAssembly(
            stepID: viewModel.stepID,
            isTeacher: viewModel.isTeacher,
            navigationBarAppearance: modalPresentationStyle.isSheetStyle ? .pageSheetAppearance() : .init()
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, embedInNavigation: false, modalPresentationStyle: modalPresentationStyle)
    }

    func displayStepTextUpdate(viewModel: LessonDataFlow.StepTextUpdate.ViewModel) {
        guard let stepModuleInput = self.stepModulesInputs[safe: viewModel.index] else {
            return
        }

        stepModuleInput?.updateStepText(viewModel.text)
    }

    func displayBlockingLoadingIndicator(viewModel: LessonDataFlow.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }

    func displayUnitNavigationRequirementNotSatisfiedState(
        viewModel: LessonDataFlow.UnitNavigationRequirementNotSatisfiedPresentation.ViewModel
    ) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("LessonUnitNavigationActionSyllabus", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("LessonUnitNavigationRequirementNotSatisfiedActionContinue", comment: ""),
                style: .cancel
            )
        )
        self.present(alert, animated: true)
    }

    func displayUnitNavigationUnreachableState(
        viewModel: LessonDataFlow.UnitNavigationUnreachablePresentation.ViewModel
    ) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true)
    }

    func displayUnitNavigationExamState(viewModel: LessonDataFlow.UnitNavigationExamPresentation.ViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("LessonUnitNavigationActionSyllabus", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            )
        )
        self.present(alert, animated: true)
    }

    func displayUnitNavigationClosedByDateState(
        viewModel: LessonDataFlow.UnitNavigationClosedByDatePresentation.ViewModel
    ) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("LessonUnitNavigationActionSyllabus", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            )
        )
        self.present(alert, animated: true)
    }

    func displayUnitNavigationFinishedDemoAccessState(
        viewModel: LessonDataFlow.UnitNavigationFinishedDemoAccessPresentation.ViewModel
    ) {
        let assembly = LessonFinishedDemoPanModalAssembly(
            sectionID: viewModel.sectionID,
            promoCodeName: viewModel.promoCodeName,
            output: self
        )
        let viewController = assembly.makeModule()
        self.presentIfPanModalWithCustomModalPresentationStyle(viewController)
    }

    func displayLessonFinishedSteps(viewModel: LessonDataFlow.LessonFinishedStepsPresentation.ViewModel) {
        let assembly = LessonFinishedStepsPanModalAssembly(
            courseID: viewModel.courseID,
            output: self
        )
        let viewController = assembly.makeModule()
        self.presentIfPanModalWithCustomModalPresentationStyle(viewController)
    }
}

// MARK: - LessonViewController: EasyTipViewDelegate -

extension LessonViewController: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {}

    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        self.isTooltipVisible = false
        self.tooltipView = nil
    }
}

// MARK: - LessonViewController: LessonFinishedDemoPanModalOutputProtocol -

extension LessonViewController: LessonFinishedDemoPanModalOutputProtocol {
    func handleLessonFinishedDemoPanModalMainAction() {
        self.dismiss(animated: true) { [weak self] in
            self?.interactor.doBuyCourse(request: .init())
        }
    }
}

// MARK: - LessonViewController: LessonFinishedStepsPanModalOutputProtocol -

extension LessonViewController: LessonFinishedStepsPanModalOutputProtocol {
    func handleLessonFinishedStepsPanModalLeaveReviewAction() {
        self.dismiss(animated: true) { [weak self] in
            self?.interactor.doLeaveReviewPresentation(request: .init())
        }
    }

    func handleLessonFinishedStepsPanModalFindNewCourseAction() {
        self.dismiss(animated: true) { [weak self] in
            self?.interactor.doCatalogPresentation(request: .init())
        }
    }
}
