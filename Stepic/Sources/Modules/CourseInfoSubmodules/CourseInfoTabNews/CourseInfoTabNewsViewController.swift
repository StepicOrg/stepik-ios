import UIKit

protocol CourseInfoTabNewsViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: CourseInfoTabNews.SomeAction.ViewModel)
}

final class CourseInfoTabNewsViewController: UIViewController {
    private let interactor: CourseInfoTabNewsInteractorProtocol

    init(interactor: CourseInfoTabNewsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseInfoTabNewsView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CourseInfoTabNewsViewController: CourseInfoTabNewsViewControllerProtocol {
    func displaySomeActionResult(viewModel: CourseInfoTabNews.SomeAction.ViewModel) {}
}
