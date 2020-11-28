import UIKit

protocol AuthorsCourseListViewControllerProtocol: AnyObject {
    func displayCourseList(viewModel: AuthorsCourseList.CourseListLoad.ViewModel)
}

final class AuthorsCourseListViewController: UIViewController {
    private let interactor: AuthorsCourseListInteractorProtocol

    var authorsCourseListView: AuthorsCourseListView? { self.view as? AuthorsCourseListView }

    private var state: AuthorsCourseList.ViewControllerState

    init(
        interactor: AuthorsCourseListInteractorProtocol,
        initialState: AuthorsCourseList.ViewControllerState = .loading
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
        let view = AuthorsCourseListView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doCourseListLoad(request: .init())
    }

    private func updateState(newState: AuthorsCourseList.ViewControllerState) {
        self.state = newState

        switch self.state {
        case .loading:
            break
            //self.authorsCourseListView?.showLoading()
        case .result(let viewModels):
            break
            //self.authorsCourseListView?.hideLoading()

//            self.collectionViewDelegate.viewModels = viewModels
//            self.collectionViewDataSource.viewModels = viewModels
//            self.authorsCourseListView?.updateCollectionViewData(
//                delegate: self.collectionViewDelegate,
//                dataSource: self.collectionViewDataSource
//            )
        }
    }
}

extension AuthorsCourseListViewController: AuthorsCourseListViewControllerProtocol {
    func displayCourseList(viewModel: AuthorsCourseList.CourseListLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}
