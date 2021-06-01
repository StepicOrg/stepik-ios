import UIKit

protocol UserCoursesReviewsBlockViewControllerProtocol: AnyObject {
    func displayReviews(viewModel: UserCoursesReviewsBlock.ReviewsLoad.ViewModel)
}

final class UserCoursesReviewsBlockViewController: UIViewController {
    private let interactor: UserCoursesReviewsBlockInteractorProtocol

    var userCoursesReviewsBlockView: UserCoursesReviewsBlockView? { self.view as? UserCoursesReviewsBlockView }

    private var state: UserCoursesReviewsBlock.ViewControllerState

    init(
        interactor: UserCoursesReviewsBlockInteractorProtocol,
        initialState: UserCoursesReviewsBlock.ViewControllerState = .loading
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
        let view = UserCoursesReviewsBlockView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doReviewsLoad(request: .init())
    }

    private func updateState(newState: UserCoursesReviewsBlock.ViewControllerState) {
        switch newState {
        case .loading:
            self.userCoursesReviewsBlockView?.showLoading()
        case .result(let viewModel):
            self.userCoursesReviewsBlockView?.hideLoading()
            self.userCoursesReviewsBlockView?.configure(viewModel: viewModel)
        }

        self.state = newState
    }
}

extension UserCoursesReviewsBlockViewController: UserCoursesReviewsBlockViewControllerProtocol {
    func displayReviews(viewModel: UserCoursesReviewsBlock.ReviewsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

extension UserCoursesReviewsBlockViewController: UserCoursesReviewsBlockViewDelegate {
    func userCoursesReviewsBlockViewDidClick(_ view: UserCoursesReviewsBlockView) {
        let assembly = UserCoursesReviewsAssembly(
            output: self.interactor as? UserCoursesReviewsOutputProtocol
        )
        self.push(module: assembly.makeModule())
    }
}
