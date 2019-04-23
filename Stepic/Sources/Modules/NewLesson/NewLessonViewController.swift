import UIKit

protocol NewLessonViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: NewLesson.SomeAction.ViewModel)
}

final class NewLessonViewController: UIViewController {
    private let interactor: NewLessonInteractorProtocol

    init(interactor: NewLessonInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewLessonView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewLessonViewController: NewLessonViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewLesson.SomeAction.ViewModel) { }
}