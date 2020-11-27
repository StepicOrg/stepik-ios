import UIKit

protocol AuthorsCourseListViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: AuthorsCourseList.SomeAction.ViewModel)
}

final class AuthorsCourseListViewController: UIViewController {
    private let interactor: AuthorsCourseListInteractorProtocol

    init(interactor: AuthorsCourseListInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = AuthorsCourseListView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension AuthorsCourseListViewController: AuthorsCourseListViewControllerProtocol {
    func displaySomeActionResult(viewModel: AuthorsCourseList.SomeAction.ViewModel) {}
}
