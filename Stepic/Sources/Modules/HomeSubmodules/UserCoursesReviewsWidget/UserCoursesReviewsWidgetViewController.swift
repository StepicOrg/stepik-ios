import UIKit

protocol UserCoursesReviewsWidgetViewControllerProtocol: AnyObject {
    func displayReviews(viewModel: UserCoursesReviewsWidget.ReviewsLoad.ViewModel)
}

final class UserCoursesReviewsWidgetViewController: UIViewController {
    private let interactor: UserCoursesReviewsWidgetInteractorProtocol

    var userCoursesReviewsWidgetView: UserCoursesReviewsWidgetView? { self.view as? UserCoursesReviewsWidgetView }

    private var state: UserCoursesReviewsWidget.ViewControllerState

    init(
        interactor: UserCoursesReviewsWidgetInteractorProtocol,
        initialState: UserCoursesReviewsWidget.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UserCoursesReviewsWidgetView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
    }

    private func updateState(newState: UserCoursesReviewsWidget.ViewControllerState) {
        switch newState {
        case .loading:
            self.userCoursesReviewsWidgetView?.showLoading()
        case .result(let viewModel):
            self.userCoursesReviewsWidgetView?.hideLoading()
            self.userCoursesReviewsWidgetView?.configure(viewModel: viewModel)
        }

        self.state = newState
    }
}

extension UserCoursesReviewsWidgetViewController: UserCoursesReviewsWidgetViewControllerProtocol {
    func displayReviews(viewModel: UserCoursesReviewsWidget.ReviewsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

extension UserCoursesReviewsWidgetViewController: UserCoursesReviewsWidgetViewDelegate {
    func userCoursesReviewsWidgetViewDidClick(_ view: UserCoursesReviewsWidgetView) {
        let assembly = UserCoursesReviewsAssembly(
            output: self.interactor as? UserCoursesReviewsOutputProtocol
        )
        self.push(module: assembly.makeModule())
    }
}
