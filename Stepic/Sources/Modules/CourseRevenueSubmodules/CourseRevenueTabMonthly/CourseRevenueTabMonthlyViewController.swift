import UIKit

protocol CourseRevenueTabMonthlyViewControllerProtocol: AnyObject {
    func displayCourseBenefitByMonths(viewModel: CourseRevenueTabMonthly.CourseBenefitByMonthsLoad.ViewModel)
    func displayNextCourseBenefitByMonths(viewModel: CourseRevenueTabMonthly.NextCourseBenefitByMonthsLoad.ViewModel)
    func displayLoadingState(viewModel: CourseRevenueTabMonthly.LoadingStatePresentation.ViewModel)
}

final class CourseRevenueTabMonthlyViewController: UIViewController {
    private let interactor: CourseRevenueTabMonthlyInteractorProtocol

    var courseRevenueTabMonthlyView: CourseRevenueTabMonthlyView? { self.view as? CourseRevenueTabMonthlyView }

    private lazy var paginationView = PaginationView()

    private var state: CourseRevenueTabMonthly.ViewControllerState {
        didSet {
            self.updateState(newState: self.state)
        }
    }
    private var canTriggerPagination = true

    private lazy var tableDataSource = CourseRevenueTabMonthlyTableViewDataSource()

    init(
        interactor: CourseRevenueTabMonthlyInteractorProtocol,
        initialState: CourseRevenueTabMonthly.ViewControllerState = .loading
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
        let view = CourseRevenueTabMonthlyView(frame: UIScreen.main.bounds)
        view.paginationView = self.paginationView
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
    }

    private func updateState(newState: CourseRevenueTabMonthly.ViewControllerState) {
        switch newState {
        case .loading:
            self.courseRevenueTabMonthlyView?.setEmptyPlaceholderVisible(false)
            self.courseRevenueTabMonthlyView?.setErrorPlaceholderVisible(false)
            self.courseRevenueTabMonthlyView?.setLoading(true)
        case .error:
            self.courseRevenueTabMonthlyView?.setEmptyPlaceholderVisible(false)
            self.courseRevenueTabMonthlyView?.setErrorPlaceholderVisible(true)
            self.courseRevenueTabMonthlyView?.setLoading(false)
        case .result(let data):
            self.courseRevenueTabMonthlyView?.setErrorPlaceholderVisible(false)
            self.courseRevenueTabMonthlyView?.setLoading(false)

            self.tableDataSource.viewModels = data.courseBenefitByMonths
            self.courseRevenueTabMonthlyView?.updateTableViewData(dataSource: self.tableDataSource)
            self.courseRevenueTabMonthlyView?.setEmptyPlaceholderVisible(self.tableDataSource.viewModels.isEmpty)

            self.updatePagination(hasNextPage: data.hasNextPage, hasError: false)
        }
    }

    private func updatePagination(hasNextPage: Bool, hasError: Bool) {
        self.canTriggerPagination = hasNextPage
        if hasNextPage {
            self.paginationView.setLoading()
            self.courseRevenueTabMonthlyView?.setPaginationViewVisible(true)
        } else {
            self.courseRevenueTabMonthlyView?.setPaginationViewVisible(false)
        }
    }
}

extension CourseRevenueTabMonthlyViewController: CourseRevenueTabMonthlyViewControllerProtocol {
    func displayCourseBenefitByMonths(viewModel: CourseRevenueTabMonthly.CourseBenefitByMonthsLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayNextCourseBenefitByMonths(viewModel: CourseRevenueTabMonthly.NextCourseBenefitByMonthsLoad.ViewModel) {
        switch (self.state, viewModel.state) {
        case (.result(let currentData), .result(let nextData)):
            self.state = .result(
                data: .init(
                    courseBenefitByMonths: currentData.courseBenefitByMonths + nextData.courseBenefitByMonths,
                    hasNextPage: nextData.hasNextPage
                )
            )
        case (_, .error):
            self.updateState(newState: self.state)
        default:
            break
        }
    }

    func displayLoadingState(viewModel: CourseRevenueTabMonthly.LoadingStatePresentation.ViewModel) {
        self.state = .loading
    }
}

extension CourseRevenueTabMonthlyViewController: CourseRevenueTabMonthlyViewDelegate {
    func courseRevenueTabMonthlyViewDidPaginationRequesting(_ view: CourseRevenueTabMonthlyView) {
        guard self.canTriggerPagination else {
            return
        }

        self.canTriggerPagination = false
        self.interactor.doNextCourseBenefitByMonthsLoad(request: .init())
    }

    func courseRevenueTabMonthlyViewDidClickErrorPlaceholderViewButton(_ view: CourseRevenueTabMonthlyView) {
        self.displayLoadingState(viewModel: .init())
        self.interactor.doCourseBenefitByMonthsLoad(request: .init())
    }
}
