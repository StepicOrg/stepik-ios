import SVProgressHUD
import UIKit

protocol CourseListViewControllerProtocol: AnyObject {
    func displayCourses(viewModel: CourseList.CoursesLoad.ViewModel)
    func displayNextCourses(viewModel: CourseList.NextCoursesLoad.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: CourseList.BlockingWaitingIndicatorUpdate.ViewModel)
}

protocol CourseListViewControllerDelegate: AnyObject {
    func itemDidSelected(viewModel: CourseWidgetViewModel)
    func primaryButtonClicked(viewModel: CourseWidgetViewModel)
}

class CourseListViewController: UIViewController {
    let interactor: CourseListInteractorProtocol

    private var state: CourseList.ViewControllerState

    // swiftlint:disable weak_delegate
    let listDelegate: CourseListCollectionViewDelegate
    let listDataSource: CourseListCollectionViewDataSource
    // swiftlint:enable weak_delegate

    lazy var courseListView = self.view as? CourseListView

    let colorMode: CourseListColorMode
    let cardStyle: CourseListCardStyle
    let gridSize: CourseListGridSize
    fileprivate var canTriggerPagination = true

    fileprivate init(
        interactor: CourseListInteractorProtocol,
        initialState: CourseList.ViewControllerState = .loading,
        colorMode: CourseListColorMode = .default,
        cardStyle: CourseListCardStyle = .default,
        gridSize: CourseListGridSize = .default,
        maxNumberOfDisplayedCourses: Int? = nil
    ) {
        self.interactor = interactor
        self.state = initialState
        self.colorMode = colorMode
        self.cardStyle = cardStyle
        self.gridSize = gridSize

        self.listDelegate = CourseListCollectionViewDelegate()
        self.listDataSource = CourseListCollectionViewDataSource(
            maxNumberOfDisplayedCourses: maxNumberOfDisplayedCourses
        )

        super.init(nibName: nil, bundle: nil)

        self.listDelegate.delegate = self
        self.listDataSource.delegate = self
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
        self.interactor.doCoursesFetch(request: .init())
    }

    func updatePagination(hasNextPage: Bool) {
        self.canTriggerPagination = hasNextPage
    }

    private func updateState(newState: CourseList.ViewControllerState) {
        if case .result = newState {
            self.courseListView?.hideLoading()
            self.courseListView?.updateCollectionViewData(
                delegate: self.listDelegate,
                dataSource: self.listDataSource
            )
        } else {
            self.courseListView?.showLoading()
        }
        self.state = newState
    }
}

extension CourseListViewController: CourseListViewControllerProtocol {
    func displayCourses(viewModel: CourseList.CoursesLoad.ViewModel) {
        if case .result(let data) = viewModel.state {
            self.listDataSource.viewModels = data.courses
            self.listDelegate.viewModels = data.courses
            self.updateState(newState: viewModel.state)
            self.updatePagination(hasNextPage: data.hasNextPage)
        }
    }

    func displayNextCourses(viewModel: CourseList.NextCoursesLoad.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.listDataSource.viewModels.append(contentsOf: data.courses)
            self.listDelegate.viewModels.append(contentsOf: data.courses)
            self.updateState(newState: self.state)
            self.updatePagination(hasNextPage: data.hasNextPage)
        case .error:
            self.updatePagination(hasNextPage: true)
        }
    }

    func displayBlockingLoadingIndicator(viewModel: CourseList.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }
}

extension CourseListViewController: CourseListViewDelegate {
    func courseListViewDidPaginationRequesting(_ courseListView: CourseListView) {
        guard self.canTriggerPagination else {
            return
        }

        self.canTriggerPagination = false
        self.interactor.doNextCoursesFetch(request: CourseList.NextCoursesLoad.Request())
    }
}

extension CourseListViewController: CourseListViewControllerDelegate {
    func itemDidSelected(viewModel: CourseWidgetViewModel) {
        self.interactor.doMainAction(
            request: .init(viewModelUniqueIdentifier: viewModel.uniqueIdentifier)
        )
    }

    func primaryButtonClicked(viewModel: CourseWidgetViewModel) {
        self.interactor.doPrimaryAction(
            request: .init(viewModelUniqueIdentifier: viewModel.uniqueIdentifier)
        )
    }
}

final class HorizontalCourseListViewController: CourseListViewController {
    override init(
        interactor: CourseListInteractorProtocol,
        initialState: CourseList.ViewControllerState = .loading,
        colorMode: CourseListColorMode = .default,
        cardStyle: CourseListCardStyle = .default,
        gridSize: CourseListGridSize = .default,
        maxNumberOfDisplayedCourses: Int? = nil
    ) {
        super.init(
            interactor: interactor,
            initialState: initialState,
            colorMode: colorMode,
            cardStyle: cardStyle,
            gridSize: gridSize,
            maxNumberOfDisplayedCourses: maxNumberOfDisplayedCourses
        )
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = HorizontalCourseListView(
            frame: UIScreen.main.bounds,
            gridSize: self.gridSize,
            colorMode: self.colorMode,
            cardStyle: self.cardStyle,
            delegate: self.listDelegate,
            dataSource: self.listDataSource,
            viewDelegate: self
        )
        self.view = view
    }
}

final class VerticalCourseListViewController: CourseListViewController {
    private let presentationDescription: CourseList.PresentationDescription?
    lazy var verticalCourseListView = self.courseListView as? VerticalCourseListView
    lazy var paginationView = self.verticalCourseListView?.paginationView as? PaginationView

    init(
        interactor: CourseListInteractorProtocol,
        initialState: CourseList.ViewControllerState = .loading,
        colorMode: CourseListColorMode = .default,
        cardStyle: CourseListCardStyle = .default,
        gridSize: CourseListGridSize = .default,
        presentationDescription: CourseList.PresentationDescription?
    ) {
        self.presentationDescription = presentationDescription
        super.init(
            interactor: interactor,
            initialState: initialState,
            colorMode: colorMode,
            cardStyle: cardStyle,
            gridSize: gridSize,
            maxNumberOfDisplayedCourses: nil
        )
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = VerticalCourseListView(
            frame: UIScreen.main.bounds,
            colorMode: self.colorMode,
            cardStyle: self.cardStyle,
            gridSize: self.gridSize,
            delegate: self.listDelegate,
            dataSource: self.listDataSource,
            viewDelegate: self,
            isHeaderViewHidden: self.presentationDescription == nil
        )

        if let presentationDescription = self.presentationDescription {
            let headerView = GradientCoursesPlaceholderViewFactory().makeFullscreenView(
                title: presentationDescription.title,
                subtitle: presentationDescription.subtitle,
                color: presentationDescription.color
            )
            view.headerView = headerView
        }

        view.paginationView = PaginationView()

        self.view = view
    }

    override func updatePagination(hasNextPage: Bool) {
        super.updatePagination(hasNextPage: hasNextPage)

        self.verticalCourseListView?.isPaginationViewHidden = !hasNextPage
        self.paginationView?.setLoading()
    }
}
