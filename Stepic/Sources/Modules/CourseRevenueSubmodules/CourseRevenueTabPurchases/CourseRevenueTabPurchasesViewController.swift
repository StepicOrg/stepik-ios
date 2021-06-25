import UIKit

protocol CourseRevenueTabPurchasesViewControllerProtocol: AnyObject {
    func displayPurchases(viewModel: CourseRevenueTabPurchases.PurchasesLoad.ViewModel)
    func displayNextPurchases(viewModel: CourseRevenueTabPurchases.NextPurchasesLoad.ViewModel)
    func displayPurchaseDetails(viewModel: CourseRevenueTabPurchases.PurchaseDetailsPresentation.ViewModel)
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

    private let tableDataSource = CourseRevenueTabPurchasesTableViewDataSource()

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

    private func updatePagination(hasNextPage: Bool, hasError: Bool) {
        self.canTriggerPagination = hasNextPage
        if hasNextPage {
            self.paginationView.setLoading()
            self.courseRevenueTabPurchasesView?.showPaginationView()
        } else {
            self.courseRevenueTabPurchasesView?.hidePaginationView()
        }
    }

    private func updateState(newState: CourseRevenueTabPurchases.ViewControllerState) {
        switch newState {
        case .loading:
            break
        case .error:
            break
        case .result(let data):
            self.tableDataSource.viewModels = data.courseBenefits
            self.courseRevenueTabPurchasesView?.updateTableViewData(dataSource: self.tableDataSource)
            self.updatePagination(hasNextPage: data.hasNextPage, hasError: false)
        }
    }
}

extension CourseRevenueTabPurchasesViewController: CourseRevenueTabPurchasesViewControllerProtocol {
    func displayPurchases(viewModel: CourseRevenueTabPurchases.PurchasesLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayNextPurchases(viewModel: CourseRevenueTabPurchases.NextPurchasesLoad.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.tableDataSource.viewModels.append(contentsOf: data.courseBenefits)
            self.updateState(newState: self.state)
            self.updatePagination(hasNextPage: data.hasNextPage, hasError: false)
        case .error:
            self.updateState(newState: self.state)
            self.updatePagination(hasNextPage: false, hasError: true)
        }
    }

    func displayPurchaseDetails(viewModel: CourseRevenueTabPurchases.PurchaseDetailsPresentation.ViewModel) {
        let assembly = CourseBenefitDetailAssembly(
            courseBenefitID: viewModel.courseBenefitID,
            moduleOutput: self
        )
        self.presentIfPanModalWithCustomModalPresentationStyle(assembly.makeModule())
    }
}

extension CourseRevenueTabPurchasesViewController: CourseRevenueTabPurchasesViewDelegate {
    func courseRevenueTabPurchasesViewDidPaginationRequesting(_ view: CourseRevenueTabPurchasesView) {
        print(#function)
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
