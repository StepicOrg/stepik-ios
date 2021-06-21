import UIKit

protocol CourseRevenueViewControllerProtocol: AnyObject {
    func displayCourseRevenue(viewModel: CourseRevenue.CourseRevenueLoad.ViewModel)
}

final class CourseRevenueViewController: UIViewController {
    private let interactor: CourseRevenueInteractorProtocol

    init(interactor: CourseRevenueInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseRevenueView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CourseRevenueViewController: CourseRevenueViewControllerProtocol {
    func displayCourseRevenue(viewModel: CourseRevenue.CourseRevenueLoad.ViewModel) {}
}
