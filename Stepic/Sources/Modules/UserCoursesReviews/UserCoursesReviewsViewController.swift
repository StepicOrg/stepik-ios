import UIKit

protocol UserCoursesReviewsViewControllerProtocol: AnyObject {
    func displayReviews(viewModel: UserCoursesReviews.ReviewsLoad.ViewModel)
}

protocol UserCoursesReviewsViewControllerDelegate: AnyObject {
    func cellDidSelect(_ cell: UserCoursesReviewsItemViewModel)
    func coverDidClick(_ cell: UserCoursesReviewsItemViewModel)
    func moreButtonDidClick(_ cell: UserCoursesReviewsItemViewModel)
    func scoreDidChange(_ score: Int, cell: UserCoursesReviewsItemViewModel)
    func sharePossibleReviewButtonDidClick(_ cell: UserCoursesReviewsItemViewModel)
}

extension UserCoursesReviewsViewController {
    enum Animation {
        static let startRefreshDelay: TimeInterval = 1.0
    }
}

final class UserCoursesReviewsViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: UserCoursesReviewsInteractorProtocol
    private let reviewsTableDataSource: UserCoursesReviewsTableViewDataSource

    var placeholderContainer = StepikPlaceholderControllerContainer()

    var userCoursesReviewsView: UserCoursesReviewsView? { self.view as? UserCoursesReviewsView }

    private var state: UserCoursesReviews.ViewControllerState

    init(
        interactor: UserCoursesReviewsInteractorProtocol,
        initialState: UserCoursesReviews.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.reviewsTableDataSource = UserCoursesReviewsTableViewDataSource()
        self.state = initialState

        super.init(nibName: nil, bundle: nil)

        self.reviewsTableDataSource.delegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UserCoursesReviewsView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.updateState(newState: self.state)

        self.interactor.doReviewsLoad(request: .init())
    }

    private func setup() {
        self.title = NSLocalizedString("UserCoursesReviewsTitle", comment: "")

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    strongSelf.interactor.doReviewsLoad(request: .init())
                }
            ),
            for: .connectionError
        )
        self.registerPlaceholder(placeholder: StepikPlaceholder(.emptyReviews, action: nil), for: .empty)
    }

    private func updateState(newState: UserCoursesReviews.ViewControllerState) {
        switch newState {
        case .loading:
            self.isPlaceholderShown = false
            self.userCoursesReviewsView?.showLoading()
        case .error:
            self.showPlaceholder(for: .connectionError)
            self.userCoursesReviewsView?.hideLoading()
        case .empty:
            self.showPlaceholder(for: .empty)
            self.userCoursesReviewsView?.hideLoading()
        case .result(let data):
            self.isPlaceholderShown = false
            self.userCoursesReviewsView?.hideLoading()

            self.reviewsTableDataSource.update(data: data)
            self.userCoursesReviewsView?.updateTableViewData(delegate: self.reviewsTableDataSource)
        }

        self.state = newState
    }
}

extension UserCoursesReviewsViewController: UserCoursesReviewsViewControllerProtocol {
    func displayReviews(viewModel: UserCoursesReviews.ReviewsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

extension UserCoursesReviewsViewController: UserCoursesReviewsViewDelegate {
    func userCoursesReviewsViewRefreshControlDidRefresh(_ view: UserCoursesReviewsView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.startRefreshDelay) { [weak self] in
            self?.interactor.doReviewsLoad(request: .init())
        }
    }
}

extension UserCoursesReviewsViewController: UserCoursesReviewsViewControllerDelegate {
    func cellDidSelect(_ cell: UserCoursesReviewsItemViewModel) {
        print(#function)
    }

    func coverDidClick(_ cell: UserCoursesReviewsItemViewModel) {
        print(#function)
    }

    func moreButtonDidClick(_ cell: UserCoursesReviewsItemViewModel) {
        print(#function)
    }

    func scoreDidChange(_ score: Int, cell: UserCoursesReviewsItemViewModel) {
        print(#function)
    }

    func sharePossibleReviewButtonDidClick(_ cell: UserCoursesReviewsItemViewModel) {
        print(#function)
    }
}
