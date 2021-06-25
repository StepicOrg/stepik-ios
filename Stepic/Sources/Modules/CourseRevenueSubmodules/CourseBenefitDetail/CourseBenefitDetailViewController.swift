import PanModal
import UIKit

protocol CourseBenefitDetailViewControllerProtocol: AnyObject {
    func displayCourseBenefit(viewModel: CourseBenefitDetail.CourseBenefitLoad.ViewModel)
}

final class CourseBenefitDetailViewController: PanModalPresentableViewController {
    private let interactor: CourseBenefitDetailInteractorProtocol

    private var state: CourseBenefitDetail.ViewControllerState

    private var hasLoadedData: Bool {
        if case .result = self.state {
            return true
        }
        return false
    }

    var courseBenefitDetailView: CourseBenefitDetailView? { self.view as? CourseBenefitDetailView }

    override var panScrollable: UIScrollView? { self.courseBenefitDetailView?.panScrollable }

    override var shortFormHeight: PanModalHeight {
        if self.hasLoadedData && self.isShortFormEnabled,
           let intrinsicContentSize = self.courseBenefitDetailView?.intrinsicContentSize {
            return .contentHeight(intrinsicContentSize.height)
        }
        return super.shortFormHeight
    }

    init(
        interactor: CourseBenefitDetailInteractorProtocol,
        initialState: CourseBenefitDetail.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseBenefitDetailView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doCourseBenefitLoad(request: .init())
    }

    private func updateState(newState: CourseBenefitDetail.ViewControllerState) {
        defer {
            self.state = newState
        }

        switch newState {
        case .result(let viewModel):
            self.courseBenefitDetailView?.hideLoading()
            self.courseBenefitDetailView?.configure(viewModel: viewModel)
        case .loading:
            self.courseBenefitDetailView?.showLoading()
        }
    }
}

extension CourseBenefitDetailViewController: CourseBenefitDetailViewControllerProtocol {
    func displayCourseBenefit(viewModel: CourseBenefitDetail.CourseBenefitLoad.ViewModel) {
        self.updateState(newState: viewModel.state)

        self.panModalSetNeedsLayoutUpdate()
        self.panModalTransition(to: .shortForm)
    }
}

extension CourseBenefitDetailViewController: CourseBenefitDetailViewDelegate {
    func courseBenefitDetailViewDidClickCloseButton(_ view: CourseBenefitDetailView) {
        self.dismiss(animated: true)
    }
}
