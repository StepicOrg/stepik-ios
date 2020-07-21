import UIKit

protocol NewProfileCreatedCoursesViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: NewProfileCreatedCourses.SomeAction.ViewModel)
}

final class NewProfileCreatedCoursesViewController: UIViewController {
    private let interactor: NewProfileCreatedCoursesInteractorProtocol

    init(interactor: NewProfileCreatedCoursesInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileCreatedCoursesView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewProfileCreatedCoursesViewController: NewProfileCreatedCoursesViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewProfileCreatedCourses.SomeAction.ViewModel) {}
}
