import PanModal
import UIKit

protocol CourseInfoPurchaseModalViewControllerProtocol: AnyObject {
    func displayModal(viewModel: CourseInfoPurchaseModal.ModalLoad.ViewModel)
}

final class CourseInfoPurchaseModalViewController: PanModalPresentableViewController {
    private let interactor: CourseInfoPurchaseModalInteractorProtocol

    private var state: CourseInfoPurchaseModal.ViewControllerState

    private var hasLoadedData: Bool {
        if case .result = self.state {
            return true
        }
        return false
    }

    var courseInfoPurchaseModalView: CourseInfoPurchaseModalView? { self.view as? CourseInfoPurchaseModalView }

    override var panScrollable: UIScrollView? { self.courseInfoPurchaseModalView?.panScrollable }

    override var shortFormHeight: PanModalHeight {
        if self.hasLoadedData && self.isShortFormEnabled,
           let intrinsicContentSize = self.courseInfoPurchaseModalView?.intrinsicContentSize {
            return .contentHeight(intrinsicContentSize.height)
        }
        return super.shortFormHeight
    }

    init(
        interactor: CourseInfoPurchaseModalInteractorProtocol,
        initialState: CourseInfoPurchaseModal.ViewControllerState = .loading
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
        let view = CourseInfoPurchaseModalView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doModalLoad(request: .init())
    }

    private func updateState(newState: CourseInfoPurchaseModal.ViewControllerState) {
        switch newState {
        case .result(let viewModel):
            self.courseInfoPurchaseModalView?.hideLoading()
            self.courseInfoPurchaseModalView?.configure(viewModel: viewModel)
        case .loading:
            self.courseInfoPurchaseModalView?.showLoading()
        }

        self.state = newState
    }
}

// MARK: - CourseInfoPurchaseModalViewController: CourseInfoPurchaseModalViewControllerProtocol -

extension CourseInfoPurchaseModalViewController: CourseInfoPurchaseModalViewControllerProtocol {
    func displayModal(viewModel: CourseInfoPurchaseModal.ModalLoad.ViewModel) {
        self.updateState(newState: viewModel.state)

        self.panModalSetNeedsLayoutUpdate()
        self.panModalTransition(to: .shortForm)
    }
}
