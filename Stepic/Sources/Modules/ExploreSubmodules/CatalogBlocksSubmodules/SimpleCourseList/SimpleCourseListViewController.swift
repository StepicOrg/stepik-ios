import UIKit

protocol SimpleCourseListViewControllerProtocol: AnyObject {
    func displayCourseList(viewModel: SimpleCourseList.CourseListLoad.ViewModel)
}

final class SimpleCourseListViewController: UIViewController {
    private let interactor: SimpleCourseListInteractorProtocol

    init(interactor: SimpleCourseListInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SimpleCourseListView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension SimpleCourseListViewController: SimpleCourseListViewControllerProtocol {
    func displayCourseList(viewModel: SimpleCourseList.CourseListLoad.ViewModel) {}
}
