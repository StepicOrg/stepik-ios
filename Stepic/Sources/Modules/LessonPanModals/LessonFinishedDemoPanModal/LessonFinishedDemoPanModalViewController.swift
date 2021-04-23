import UIKit

protocol LessonFinishedDemoPanModalViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: LessonFinishedDemoPanModal.SomeAction.ViewModel)
}

final class LessonFinishedDemoPanModalViewController: UIViewController {
    private let interactor: LessonFinishedDemoPanModalInteractorProtocol

    init(interactor: LessonFinishedDemoPanModalInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = LessonFinishedDemoPanModalView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension LessonFinishedDemoPanModalViewController: LessonFinishedDemoPanModalViewControllerProtocol {
    func displaySomeActionResult(viewModel: LessonFinishedDemoPanModal.SomeAction.ViewModel) {}
}
