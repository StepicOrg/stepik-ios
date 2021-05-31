import SVProgressHUD
import UIKit

protocol UserCoursesReviewsViewControllerProtocol: AnyObject {
    func displayReviews(viewModel: UserCoursesReviews.ReviewsLoad.ViewModel)
    func displayCourseInfo(viewModel: UserCoursesReviews.CourseInfoPresentation.ViewModel)
    func displayWritePossibleCourseReview(viewModel: UserCoursesReviews.WritePossibleCourseReviewPresentation.ViewModel)
    func displayEditLeavedCourseReview(viewModel: UserCoursesReviews.EditLeavedCourseReviewPresentation.ViewModel)
    func displayLeavedCourseReviewActionSheet(
        viewModel: UserCoursesReviews.LeavedCourseReviewActionSheetPresentation.ViewModel
    )

    func displayBlockingLoadingIndicator(viewModel: UserCoursesReviews.BlockingWaitingIndicatorUpdate.ViewModel)
    func displayBlockingLoadingIndicatorWithStatus(
        viewModel: UserCoursesReviews.BlockingWaitingIndicatorStatusUpdate.ViewModel
    )
}

protocol UserCoursesReviewsViewControllerDelegate: AnyObject {
    func cellDidSelect(_ cell: UserCoursesReviewsItemViewModel, anchorView: UIView?)
    func coverDidClick(_ cell: UserCoursesReviewsItemViewModel)
    func moreButtonDidClick(_ cell: UserCoursesReviewsItemViewModel, anchorView: UIView)
    func possibleReviewScoreDidChange(_ score: Int, cell: UserCoursesReviewsItemViewModel)
    func sharePossibleReviewButtonDidClick(_ cell: UserCoursesReviewsItemViewModel)
}

extension UserCoursesReviewsViewController {
    enum Animation {
        static let startRefreshDelay: TimeInterval = 1.0
        static let possibleReviewScoreUpdateDelay: TimeInterval = 0.33
    }
}

final class UserCoursesReviewsViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: UserCoursesReviewsInteractorProtocol
    private let reviewsTableDataSource: UserCoursesReviewsTableViewDataSource

    var placeholderContainer = StepikPlaceholderControllerContainer()

    var userCoursesReviewsView: UserCoursesReviewsView? { self.view as? UserCoursesReviewsView }

    private var state: UserCoursesReviews.ViewControllerState

    private weak var currentAnchorView: UIView?

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

    func displayCourseInfo(viewModel: UserCoursesReviews.CourseInfoPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(
            courseID: viewModel.courseID,
            initialTab: .reviews,
            courseViewSource: .userCoursesReviews
        )
        self.push(module: assembly.makeModule())
    }

    func displayWritePossibleCourseReview(
        viewModel: UserCoursesReviews.WritePossibleCourseReviewPresentation.ViewModel
    ) {
        let modalPresentationStyle = UIModalPresentationStyle.stepikAutomatic

        let assembly = WriteCourseReviewAssembly(
            courseID: viewModel.courseReviewPlainObject.courseID,
            presentationContext: .create(viewModel.courseReviewPlainObject),
            navigationBarAppearance: modalPresentationStyle.isSheetStyle ? .pageSheetAppearance() : .init(),
            output: self.interactor as? WriteCourseReviewOutputProtocol
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, modalPresentationStyle: modalPresentationStyle)
    }

    func displayEditLeavedCourseReview(viewModel: UserCoursesReviews.EditLeavedCourseReviewPresentation.ViewModel) {
        let modalPresentationStyle = UIModalPresentationStyle.stepikAutomatic

        let assembly = WriteCourseReviewAssembly(
            courseID: viewModel.courseReview.courseID,
            presentationContext: .update(viewModel.courseReview),
            navigationBarAppearance: modalPresentationStyle.isSheetStyle ? .pageSheetAppearance() : .init(),
            output: self.interactor as? WriteCourseReviewOutputProtocol
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, modalPresentationStyle: modalPresentationStyle)
    }

    func displayLeavedCourseReviewActionSheet(
        viewModel: UserCoursesReviews.LeavedCourseReviewActionSheetPresentation.ViewModel
    ) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("WriteCourseReviewActionEdit", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.interactor.doEditLeavedCourseReviewPresentation(
                        request: .init(viewModelUniqueIdentifier: viewModel.viewModelUniqueIdentifier)
                    )
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("WriteCourseReviewActionDelete", comment: ""),
                style: .destructive,
                handler: { [weak self] _ in
                    self?.interactor.doDeleteLeavedCourseReview(
                        request: .init(viewModelUniqueIdentifier: viewModel.viewModelUniqueIdentifier)
                    )
                }
            )
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        if let popoverPresentationController = alert.popoverPresentationController {
            let sourceView: UIView = self.currentAnchorView ?? self.view
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceView.bounds
        }

        self.present(alert, animated: true)
    }

    func displayBlockingLoadingIndicator(viewModel: UserCoursesReviews.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }

    func displayBlockingLoadingIndicatorWithStatus(
        viewModel: UserCoursesReviews.BlockingWaitingIndicatorStatusUpdate.ViewModel
    ) {
        if viewModel.success {
            SVProgressHUD.showSuccess(withStatus: nil)
        } else {
            SVProgressHUD.showError(withStatus: nil)
        }
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
    func cellDidSelect(_ cell: UserCoursesReviewsItemViewModel, anchorView: UIView?) {
        self.currentAnchorView = anchorView
        self.interactor.doMainReviewAction(request: .init(viewModelUniqueIdentifier: cell.uniqueIdentifier))
    }

    func coverDidClick(_ cell: UserCoursesReviewsItemViewModel) {
        self.interactor.doCourseInfoPresentation(request: .init(viewModelUniqueIdentifier: cell.uniqueIdentifier))
    }

    func moreButtonDidClick(_ cell: UserCoursesReviewsItemViewModel, anchorView: UIView) {
        self.currentAnchorView = anchorView
        self.interactor.doLeavedCourseReviewActionSheetPresentation(
            request: .init(viewModelUniqueIdentifier: cell.uniqueIdentifier)
        )
    }

    func possibleReviewScoreDidChange(_ score: Int, cell: UserCoursesReviewsItemViewModel) {
        self.interactor.doPossibleCourseReviewScoreUpdate(
            request: .init(viewModelUniqueIdentifier: cell.uniqueIdentifier, score: score)
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.possibleReviewScoreUpdateDelay) { [weak self] in
            self?.interactor.doWritePossibleCourseReviewPresentation(
                request: .init(viewModelUniqueIdentifier: cell.uniqueIdentifier)
            )
        }
    }

    func sharePossibleReviewButtonDidClick(_ cell: UserCoursesReviewsItemViewModel) {
        self.interactor.doWritePossibleCourseReviewPresentation(
            request: .init(viewModelUniqueIdentifier: cell.uniqueIdentifier)
        )
    }
}
