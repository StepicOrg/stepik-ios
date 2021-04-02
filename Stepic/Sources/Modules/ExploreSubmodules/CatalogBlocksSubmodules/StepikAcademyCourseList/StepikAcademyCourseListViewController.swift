import UIKit

protocol StepikAcademyCourseListViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: StepikAcademyCourseList.SomeAction.ViewModel)
}

final class StepikAcademyCourseListViewController: UIViewController {
    private let interactor: StepikAcademyCourseListInteractorProtocol

    init(interactor: StepikAcademyCourseListInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = StepikAcademyCourseListView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension StepikAcademyCourseListViewController: StepikAcademyCourseListViewControllerProtocol {
    func displaySomeActionResult(viewModel: StepikAcademyCourseList.SomeAction.ViewModel) {}
}
