import UIKit

protocol CourseInfoTabNewsViewControllerProtocol: AnyObject {
    func displayCourseNews(viewModel: CourseInfoTabNews.NewsLoad.ViewModel)
}

final class CourseInfoTabNewsViewController: UIViewController {
    private let interactor: CourseInfoTabNewsInteractorProtocol

    var courseInfoTabNewsView: CourseInfoTabNewsView? { self.view as? CourseInfoTabNewsView }

    private var state: CourseInfoTabNews.ViewControllerState
    private var canTriggerPagination = false {
        didSet {
            self.tableViewAdapter.canTriggerPagination = self.canTriggerPagination
        }
    }

    private lazy var tableViewAdapter = CourseInfoTabNewsTableViewAdapter(delegate: self)

    init(
        interactor: CourseInfoTabNewsInteractorProtocol,
        initialState: CourseInfoTabNews.ViewControllerState = .loading
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
        let view = CourseInfoTabNewsView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    // MARK: Private API

    private func updateState(newState: CourseInfoTabNews.ViewControllerState) {
        switch newState {
        case .loading:
            self.courseInfoTabNewsView?.hideErrorPlaceholder()
            self.courseInfoTabNewsView?.showLoading()
        case .error:
            self.courseInfoTabNewsView?.hideLoading()
            self.courseInfoTabNewsView?.showErrorPlaceholder()
        case .result(let data):
            self.courseInfoTabNewsView?.hideLoading()
            self.courseInfoTabNewsView?.hideErrorPlaceholder()

            self.tableViewAdapter.viewModels = data.news
            self.courseInfoTabNewsView?.updateTableViewData(delegate: self.tableViewAdapter)

            if data.news.isEmpty {
                self.courseInfoTabNewsView?.showEmptyPlaceholder()
            }

            self.updatePagination(hasNextPage: data.hasNextPage)
        }

        self.state = newState
    }

    private func updatePagination(hasNextPage: Bool) {
        self.canTriggerPagination = hasNextPage

        if hasNextPage {
            self.courseInfoTabNewsView?.showPaginationView()
        } else {
            self.courseInfoTabNewsView?.hidePaginationView()
        }
    }
}

// MARK: - CourseInfoTabNewsViewController: CourseInfoTabNewsViewControllerProtocol -

extension CourseInfoTabNewsViewController: CourseInfoTabNewsViewControllerProtocol {
    func displayCourseNews(viewModel: CourseInfoTabNews.NewsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

// MARK: - CourseInfoTabNewsViewController: CourseInfoTabNewsViewDelegate -

extension CourseInfoTabNewsViewController: CourseInfoTabNewsViewDelegate {
    func courseInfoTabNewsViewDidRequestPagination(_ view: CourseInfoTabNewsView) {
    }

    func courseInfoTabNewsViewDidClickErrorPlaceholderActionButton(_ view: CourseInfoTabNewsView) {
        self.updateState(newState: .loading)
        self.interactor.doCourseNewsFetch(request: .init())
    }
}

// MARK: - CourseInfoTabNewsViewController: CourseInfoTabNewsTableViewAdapterDelegate -

extension CourseInfoTabNewsViewController: CourseInfoTabNewsTableViewAdapterDelegate {
    func courseInfoTabNewsTableViewAdapterDidRequestPagination(_ adapter: CourseInfoTabNewsTableViewAdapter) {}

    func courseInfoTabNewsTableViewAdapter(
        _ adapter: CourseInfoTabNewsTableViewAdapter,
        scrollViewDidScroll scrollView: UIScrollView
    ) {
        self.courseInfoTabNewsView?.scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
}
