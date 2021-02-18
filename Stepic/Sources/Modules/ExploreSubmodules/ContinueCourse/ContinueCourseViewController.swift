import UIKit

protocol ContinueCourseViewControllerProtocol: AnyObject {
    func displayLastCourse(viewModel: ContinueCourse.LastCourseLoad.ViewModel)
    func displayTooltip(viewModel: ContinueCourse.TooltipAvailabilityCheck.ViewModel)
}

final class ContinueCourseViewController: UIViewController {
    private let interactor: ContinueCourseInteractorProtocol
    private var state: ContinueCourse.ViewControllerState

    lazy var continueCourseView = self.view as? ContinueCourseView
    private lazy var continueLearningTooltip = TooltipFactory.continueLearningWidget

    init(
        interactor: ContinueCourseInteractorProtocol,
        initialState: ContinueCourse.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = ContinueCourseView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.interactor.doLastCourseRefresh(request: .init())
    }

    private func updateState(newState: ContinueCourse.ViewControllerState) {
        defer {
            self.state = newState
        }

        self.continueCourseView?.hideLoading()
        self.continueCourseView?.hideEmpty()

        switch newState {
        case .loading:
            self.continueCourseView?.showLoading()
        case .empty:
            self.continueCourseView?.showEmpty()
        case .result(let viewModel):
            self.continueCourseView?.configure(viewModel: viewModel)
            self.interactor.doTooltipAvailabilityCheck(request: .init())
        }
    }
}

extension ContinueCourseViewController: ContinueCourseViewControllerProtocol {
    func displayLastCourse(viewModel: ContinueCourse.LastCourseLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayTooltip(viewModel: ContinueCourse.TooltipAvailabilityCheck.ViewModel) {
        guard let continueCourseView = self.continueCourseView,
              let parentView = self.parent?.view else {
            return
        }

        if viewModel.shouldShowTooltip {
            // Cause anchor should be in true position
            DispatchQueue.main.async { [weak self] in
                continueCourseView.setNeedsLayout()
                continueCourseView.layoutIfNeeded()
                self?.continueLearningTooltip.show(
                    direction: .down,
                    in: parentView,
                    from: continueCourseView.tooltipAnchorView
                )
            }
        }
    }
}

extension ContinueCourseViewController: ContinueCourseViewDelegate {
    func continueCourseDidClickContinue(_ continueCourseView: ContinueCourseView) {
        self.interactor.doContinueLastCourseAction(request: .init())
    }

    func continueCourseDidClickEmpty(_ continueCourseView: ContinueCourseView) {
        DeepLinkRouter.routeToCatalog()
    }
}
