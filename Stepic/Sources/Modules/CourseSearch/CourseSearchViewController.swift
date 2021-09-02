import UIKit

protocol CourseSearchViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: CourseSearch.SomeAction.ViewModel)
}

final class CourseSearchViewController: UIViewController {
    private let interactor: CourseSearchInteractorProtocol

    init(interactor: CourseSearchInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseSearchView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CourseSearchViewController: CourseSearchViewControllerProtocol {
    func displaySomeActionResult(viewModel: CourseSearch.SomeAction.ViewModel) {}
}
