import UIKit

protocol CourseRevenueViewControllerProtocol: AnyObject {
    func displayCourseRevenue(viewModel: CourseRevenue.CourseRevenueLoad.ViewModel)
}

final class CourseRevenueViewController: UIViewController {
    private let interactor: CourseRevenueInteractorProtocol

    var courseRevenueView: CourseRevenueView? { self.view as? CourseRevenueView }

    private var currentState: CourseRevenue.ViewControllerState {
        didSet {
            self.updateState(newState: self.currentState)
        }
    }

    init(
        interactor: CourseRevenueInteractorProtocol,
        initialState: CourseRevenue.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.currentState = initialState
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("CourseRevenueTitle", comment: "")

        self.updateState(newState: self.currentState)
        self.interactor.doCourseRevenueLoad(request: .init())
    }

    private func updateState(newState: CourseRevenue.ViewControllerState) {
        switch newState {
        case .loading:
            break
        case .error:
            break
        case .empty:
            break
        case .result(let viewModel):
            self.courseRevenueView?.configure(viewModel: viewModel)
        }
    }
}

extension CourseRevenueViewController: CourseRevenueViewControllerProtocol {
    func displayCourseRevenue(viewModel: CourseRevenue.CourseRevenueLoad.ViewModel) {
        self.currentState = viewModel.state
    }
}
