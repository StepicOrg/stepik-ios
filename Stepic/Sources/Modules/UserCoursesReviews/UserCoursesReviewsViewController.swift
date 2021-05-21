import UIKit

protocol UserCoursesReviewsViewControllerProtocol: AnyObject {
    func displayReviews(viewModel: UserCoursesReviews.ReviewsLoad.ViewModel)
}

final class UserCoursesReviewsViewController: UIViewController {
    private let interactor: UserCoursesReviewsInteractorProtocol

    init(interactor: UserCoursesReviewsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UserCoursesReviewsView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension UserCoursesReviewsViewController: UserCoursesReviewsViewControllerProtocol {
    func displayReviews(viewModel: UserCoursesReviews.ReviewsLoad.ViewModel) {}
}
