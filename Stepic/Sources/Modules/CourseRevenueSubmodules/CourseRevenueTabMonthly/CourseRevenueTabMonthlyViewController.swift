import UIKit

protocol CourseRevenueTabMonthlyViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: CourseRevenueTabMonthly.SomeAction.ViewModel)
}

final class CourseRevenueTabMonthlyViewController: UIViewController {
    private let interactor: CourseRevenueTabMonthlyInteractorProtocol

    init(interactor: CourseRevenueTabMonthlyInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseRevenueTabMonthlyView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CourseRevenueTabMonthlyViewController: CourseRevenueTabMonthlyViewControllerProtocol {
    func displaySomeActionResult(viewModel: CourseRevenueTabMonthly.SomeAction.ViewModel) {}
}
