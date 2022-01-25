import PanModal
import UIKit

protocol LessonFinishedDemoPanModalViewControllerProtocol: AnyObject {
    func displayModal(viewModel: LessonFinishedDemoPanModal.ModalLoad.ViewModel)
}

final class LessonFinishedDemoPanModalViewController: PanModalPresentableViewController {
    private let interactor: LessonFinishedDemoPanModalInteractorProtocol

    private var state: LessonFinishedDemoPanModal.ViewControllerState

    private var hasLoadedData: Bool {
        switch self.state {
        case .loading, .error:
            return false
        default:
            return true
        }
    }

    var lessonFinishedDemoPanModalView: LessonFinishedDemoPanModalView? { self.view as? LessonFinishedDemoPanModalView }

    override var panScrollable: UIScrollView? { self.lessonFinishedDemoPanModalView?.panScrollable }

    override var shortFormHeight: PanModalHeight {
        if self.hasLoadedData && self.isShortFormEnabled,
           let intrinsicContentSize = self.lessonFinishedDemoPanModalView?.intrinsicContentSize {
            return .contentHeight(intrinsicContentSize.height)
        }
        return super.shortFormHeight
    }

    init(
        interactor: LessonFinishedDemoPanModalInteractorProtocol,
        initialState: LessonFinishedDemoPanModal.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        super.init()
    }

    override func loadView() {
        let view = LessonFinishedDemoPanModalView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doModalLoad(request: .init())
    }

    // MARK: Private API

    private func updateState(newState: LessonFinishedDemoPanModal.ViewControllerState) {
        self.lessonFinishedDemoPanModalView?.hideLoading()
        self.lessonFinishedDemoPanModalView?.hideErrorPlaceholder()

        switch newState {
        case .loading:
            self.lessonFinishedDemoPanModalView?.showLoading()
        case .error:
            self.lessonFinishedDemoPanModalView?.showErrorPlaceholder()
        case .result(let viewModel):
            self.lessonFinishedDemoPanModalView?.configure(viewModel: viewModel)
        }

        self.state = newState
        self.transition(to: .shortForm)
    }

    private func transition(to state: PanModalPresentationController.PresentationState) {
        if state == .shortForm {
            self.isShortFormEnabled = true
        }

        DispatchQueue.main.async {
            self.panModalSetNeedsLayoutUpdate()
            self.panModalTransition(to: state)
        }
    }
}

extension LessonFinishedDemoPanModalViewController: LessonFinishedDemoPanModalViewControllerProtocol {
    func displayModal(viewModel: LessonFinishedDemoPanModal.ModalLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

// MARK: - LessonFinishedDemoPanModalViewController: LessonFinishedDemoPanModalViewDelegate -

extension LessonFinishedDemoPanModalViewController: LessonFinishedDemoPanModalViewDelegate {
    func lessonFinishedDemoPanModalViewDidClickCloseButton(_ view: LessonFinishedDemoPanModalView) {
        self.dismiss(animated: true)
    }

    func lessonFinishedDemoPanModalViewDidClickBuyButton(_ view: LessonFinishedDemoPanModalView) {
        self.interactor.doModalMainAction(request: .init())
    }

    func lessonFinishedDemoPanModalViewDidClickWishlistButton(_ view: LessonFinishedDemoPanModalView) {
        print("\(#function)")
    }

    func lessonFinishedDemoPanModalViewDidClickErrorPlaceholderActionButton(_ view: LessonFinishedDemoPanModalView) {
        self.updateState(newState: .loading)
        self.interactor.doModalLoad(request: .init())
    }
}
