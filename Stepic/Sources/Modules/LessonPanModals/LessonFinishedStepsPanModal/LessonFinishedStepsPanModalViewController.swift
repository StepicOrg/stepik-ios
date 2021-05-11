import PanModal
import UIKit

protocol LessonFinishedStepsPanModalViewControllerProtocol: AnyObject {
    func displayModal(viewModel: LessonFinishedStepsPanModal.ModalLoad.ViewModel)
}

final class LessonFinishedStepsPanModalViewController: PanModalPresentableViewController {
    private let interactor: LessonFinishedStepsPanModalInteractorProtocol

    private var state: LessonFinishedStepsPanModal.ViewControllerState

    private var hasLoadedData: Bool {
        if case .result = self.state {
            return true
        }
        return false
    }

    var lessonFinishedStepsPanModalView: LessonFinishedStepsPanModalView? {
        self.view as? LessonFinishedStepsPanModalView
    }

    override var panScrollable: UIScrollView? { self.lessonFinishedStepsPanModalView?.panScrollable }

    override var shortFormHeight: PanModalHeight {
        if self.hasLoadedData && self.isShortFormEnabled,
           let intrinsicContentSize = self.lessonFinishedStepsPanModalView?.intrinsicContentSize {
            return .contentHeight(intrinsicContentSize.height)
        }
        return super.shortFormHeight
    }

    init(
        interactor: LessonFinishedStepsPanModalInteractorProtocol,
        initialState: LessonFinishedStepsPanModal.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init()
    }

    override func loadView() {
        let view = LessonFinishedStepsPanModalView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doModalLoad(request: .init())
    }

    private func updateState(newState: LessonFinishedStepsPanModal.ViewControllerState) {
        defer {
            self.state = newState
        }

        switch newState {
        case .result(let viewModel):
            self.lessonFinishedStepsPanModalView?.hideLoading()
            self.lessonFinishedStepsPanModalView?.configure(viewModel: viewModel)
        case .loading:
            self.lessonFinishedStepsPanModalView?.showLoading()
        }
    }
}

extension LessonFinishedStepsPanModalViewController: LessonFinishedStepsPanModalViewControllerProtocol {
    func displayModal(viewModel: LessonFinishedStepsPanModal.ModalLoad.ViewModel) {
        self.updateState(newState: viewModel.state)

        self.panModalSetNeedsLayoutUpdate()
        self.panModalTransition(to: .shortForm)
    }
}

extension LessonFinishedStepsPanModalViewController: LessonFinishedStepsPanModalViewDelegate {
    func lessonFinishedStepsPanModalViewDidClickCloseButton(_ view: LessonFinishedStepsPanModalView) {
        self.dismiss(animated: true)
    }

    func lessonFinishedStepsPanModalViewDidClickPrimaryActionButton(_ view: LessonFinishedStepsPanModalView) {
        self.dismiss(animated: true)
    }

    func lessonFinishedStepsPanModalViewDidClickSecondaryActionButton(_ view: LessonFinishedStepsPanModalView) {
        print(#function)
    }
}
