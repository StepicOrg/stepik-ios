import UIKit

protocol LessonFinishedStepsPanModalViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: LessonFinishedStepsPanModal.SomeAction.ViewModel)
}

final class LessonFinishedStepsPanModalViewController: UIViewController {
    private let interactor: LessonFinishedStepsPanModalInteractorProtocol

    init(interactor: LessonFinishedStepsPanModalInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = LessonFinishedStepsPanModalView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension LessonFinishedStepsPanModalViewController: LessonFinishedStepsPanModalViewControllerProtocol {
    func displaySomeActionResult(viewModel: LessonFinishedStepsPanModal.SomeAction.ViewModel) {}
}
