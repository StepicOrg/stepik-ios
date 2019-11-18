import UIKit

protocol EditLessonViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: EditLesson.SomeAction.ViewModel)
}

final class EditLessonViewController: UIViewController {
    private let interactor: EditLessonInteractorProtocol

    init(interactor: EditLessonInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = EditLessonView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension EditLessonViewController: EditLessonViewControllerProtocol {
    func displaySomeActionResult(viewModel: EditLesson.SomeAction.ViewModel) { }
}