import UIKit

protocol CourseRevenueTabPurchasesViewControllerProtocol: AnyObject {
    func displayPurchases(viewModel: CourseRevenueTabPurchases.PurchasesLoad.ViewModel)
    func displayNextPurchases(viewModel: CourseRevenueTabPurchases.NextPurchasesLoad.ViewModel)
    func displayPurchaseDetails(viewModel: CourseRevenueTabPurchases.PurchaseDetailsPresentation.ViewModel)
    func displayLoadingState(viewModel: CourseRevenueTabPurchases.LoadingStatePresentation.ViewModel)
}

final class CourseRevenueTabPurchasesViewController: UIViewController {
    private let interactor: CourseRevenueTabPurchasesInteractorProtocol

    var courseRevenueTabPurchasesView: CourseRevenueTabPurchasesView? { self.view as? CourseRevenueTabPurchasesView }

    private lazy var paginationView = PaginationView()

    private var state: CourseRevenueTabPurchases.ViewControllerState {
        didSet {
            self.updateState(newState: self.state)
        }
    }
    private var canTriggerPagination = true

    private lazy var tableDataSource = CourseRevenueTabPurchasesTableViewDataSource(delegate: self)

    init(
        interactor: CourseRevenueTabPurchasesInteractorProtocol,
        initialState: CourseRevenueTabPurchases.ViewControllerState = .loading
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
        let view = CourseRevenueTabPurchasesView(frame: UIScreen.main.bounds)
        view.paginationView = self.paginationView
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
    }

    private func updateState(newState: CourseRevenueTabPurchases.ViewControllerState) {
        switch newState {
        case .loading:
            self.courseRevenueTabPurchasesView?.setEmptyPlaceholderVisible(false)
            self.courseRevenueTabPurchasesView?.setErrorPlaceholderVisible(false)
            self.courseRevenueTabPurchasesView?.setLoading(true)
        case .error:
            self.courseRevenueTabPurchasesView?.setEmptyPlaceholderVisible(false)
            self.courseRevenueTabPurchasesView?.setErrorPlaceholderVisible(true)
            self.courseRevenueTabPurchasesView?.setLoading(false)
        case .result(let data):
            self.courseRevenueTabPurchasesView?.setErrorPlaceholderVisible(false)
            self.courseRevenueTabPurchasesView?.setLoading(false)

            self.tableDataSource.viewModels = data.courseBenefits
            self.courseRevenueTabPurchasesView?.updateTableViewData(dataSource: self.tableDataSource)
            self.courseRevenueTabPurchasesView?.setEmptyPlaceholderVisible(self.tableDataSource.viewModels.isEmpty)

            self.updatePagination(hasNextPage: data.hasNextPage, hasError: false)
        }
    }

    private func updatePagination(hasNextPage: Bool, hasError: Bool) {
        self.canTriggerPagination = hasNextPage
        if hasNextPage {
            self.paginationView.setLoading()
            self.courseRevenueTabPurchasesView?.setPaginationViewVisible(true)
        } else {
            self.courseRevenueTabPurchasesView?.setPaginationViewVisible(false)
        }
    }
}

extension CourseRevenueTabPurchasesViewController: CourseRevenueTabPurchasesViewControllerProtocol {
    func displayPurchases(viewModel: CourseRevenueTabPurchases.PurchasesLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayNextPurchases(viewModel: CourseRevenueTabPurchases.NextPurchasesLoad.ViewModel) {
        switch (self.state, viewModel.state) {
        case (.result(let currentData), .result(let nextData)):
            self.state = .result(
                data: .init(
                    courseBenefits: currentData.courseBenefits + nextData.courseBenefits,
                    hasNextPage: nextData.hasNextPage
                )
            )
        case (_, .error):
            self.updateState(newState: self.state)
        default:
            break
        }
    }

    func displayPurchaseDetails(viewModel: CourseRevenueTabPurchases.PurchaseDetailsPresentation.ViewModel) {
        let assembly = CourseBenefitDetailAssembly(
            courseBenefitID: viewModel.courseBenefitID,
            moduleOutput: self
        )
        self.presentIfPanModalWithCustomModalPresentationStyle(assembly.makeModule())
    }

    func displayLoadingState(viewModel: CourseRevenueTabPurchases.LoadingStatePresentation.ViewModel) {
        self.state = .loading
    }
}

extension CourseRevenueTabPurchasesViewController: CourseRevenueTabPurchasesViewDelegate {
    func courseRevenueTabPurchasesViewDidPaginationRequesting(_ view: CourseRevenueTabPurchasesView) {
        guard self.canTriggerPagination else {
            return
        }

        self.canTriggerPagination = false
        self.interactor.doNextPurchasesLoad(request: .init())
    }

    func courseRevenueTabPurchasesView(_ view: CourseRevenueTabPurchasesView, didSelectRowAt indexPath: IndexPath) {
        guard case .result(let data) = self.state,
              let targetCourseBenefit = data.courseBenefits[safe: indexPath.row] else {
            return
        }

        self.interactor.doPurchaseDetailsPresentation(
            request: .init(viewModelUniqueIdentifier: targetCourseBenefit.uniqueIdentifier)
        )
    }

    func courseRevenueTabPurchasesViewDidClickErrorPlaceholderViewButton(_ view: CourseRevenueTabPurchasesView) {
        self.state = .loading
        self.interactor.doPurchasesLoad(request: .init())
    }
}

extension CourseRevenueTabPurchasesViewController: CourseRevenueTabPurchasesTableViewDataSourceDelegate {
    func courseRevenueTabPurchasesTableViewDataSource(
        _ dataSource: CourseRevenueTabPurchasesTableViewDataSource,
        didSelectBuyer viewModel: CourseRevenueTabPurchasesViewModel
    ) {
        self.interactor.doBuyerProfilePresentation(
            request: .init(viewModelUniqueIdentifier: viewModel.uniqueIdentifier)
        )
    }
}

extension CourseRevenueTabPurchasesViewController: CourseBenefitDetailOutputProtocol {
    func handleCourseBenefitDetailDidRequestPresentCourseInfo(courseID: Course.IdType) {
        self.dismiss(animated: true) { [weak self] in
            self?.interactor.doCourseInfoPresentation(request: .init(courseID: courseID))
        }
    }

    func handleCourseBenefitDetailDidRequestPresentUser(userID: User.IdType) {
        self.dismiss(animated: true) { [weak self] in
            self?.interactor.doProfilePresentation(request: .init(userID: userID))
        }
    }
}
