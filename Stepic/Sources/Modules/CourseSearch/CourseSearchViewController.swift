import UIKit

protocol CourseSearchViewControllerProtocol: AnyObject {
    func displayCourseContent(viewModel: CourseSearch.CourseContentLoad.ViewModel)
}

final class CourseSearchViewController: UIViewController {
    private let interactor: CourseSearchInteractorProtocol

    private lazy var searchBar = CourseSearchBar()

    private var courseSearchView: CourseSearchView? { self.view as? CourseSearchView }

    init(interactor: CourseSearchInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        self.searchBar.searchBarDelegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseSearchView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.styledNavigationController?.removeBackButtonTitleForTopController()
        self.navigationItem.titleView = self.searchBar

        self.interactor.doCourseContentLoad(request: .init())
    }
}

extension CourseSearchViewController: CourseSearchViewControllerProtocol {
    func displayCourseContent(viewModel: CourseSearch.CourseContentLoad.ViewModel) {}
}

extension CourseSearchViewController: CourseSearchBarDelegate {
}
