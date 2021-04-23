import PanModal
import UIKit

protocol LessonFinishedDemoPanModalViewControllerProtocol: AnyObject {
    func displayModal(viewModel: LessonFinishedDemoPanModal.ModalLoad.ViewModel)
}

final class LessonFinishedDemoPanModalViewController: PanModalPresentableViewController {
    private let interactor: LessonFinishedDemoPanModalInteractorProtocol

    private var hasLoadedData = false

    var lessonFinishedDemoPanModalView: LessonFinishedDemoPanModalView? { self.view as? LessonFinishedDemoPanModalView }

    override var panScrollable: UIScrollView? { self.lessonFinishedDemoPanModalView?.panScrollable }

    override var shortFormHeight: PanModalHeight {
        if self.hasLoadedData && self.isShortFormEnabled,
           let intrinsicContentSize = self.lessonFinishedDemoPanModalView?.intrinsicContentSize {
            return .contentHeight(intrinsicContentSize.height)
        }
        return super.shortFormHeight
    }

    init(interactor: LessonFinishedDemoPanModalInteractorProtocol) {
        self.interactor = interactor
        super.init()
    }

    override func loadView() {
        let view = LessonFinishedDemoPanModalView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.doModalLoad(request: .init())
    }
}

extension LessonFinishedDemoPanModalViewController: LessonFinishedDemoPanModalViewControllerProtocol {
    func displayModal(viewModel: LessonFinishedDemoPanModal.ModalLoad.ViewModel) {
        self.lessonFinishedDemoPanModalView?.title = viewModel.title
        self.lessonFinishedDemoPanModalView?.subtitle = viewModel.subtitle
        self.lessonFinishedDemoPanModalView?.actionButtonTitle = viewModel.actionButtonTitle

        self.hasLoadedData = true

        self.panModalSetNeedsLayoutUpdate()
        self.panModalTransition(to: .shortForm)
    }
}

extension LessonFinishedDemoPanModalViewController: LessonFinishedDemoPanModalViewDelegate {
    func lessonFinishedDemoPanModalViewDidClickCloseButton(_ view: LessonFinishedDemoPanModalView) {
        self.dismiss(animated: true)
    }

    func lessonFinishedDemoPanModalViewDidClickActionButton(_ view: LessonFinishedDemoPanModalView) {
        self.interactor.doModalMainAction(request: .init())
    }
}
