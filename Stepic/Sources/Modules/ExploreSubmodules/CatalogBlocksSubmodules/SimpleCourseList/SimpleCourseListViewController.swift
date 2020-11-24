import UIKit

protocol SimpleCourseListViewControllerProtocol: AnyObject {
    func displayCourseList(viewModel: SimpleCourseList.CourseListLoad.ViewModel)
}

protocol SimpleCourseListViewControllerDelegate: AnyObject {
    func itemDidSelected(viewModel: SimpleCourseListWidgetViewModel)
}

final class SimpleCourseListViewController: UIViewController {
    private let interactor: SimpleCourseListInteractorProtocol

    var simpleCourseListView: SimpleCourseListView? { self.view as? SimpleCourseListView }

    // swiftlint:disable weak_delegate
    private let collectionViewDelegate = SimpleCourseListCollectionViewDelegate()
    private let collectionViewDataSource = SimpleCourseListCollectionViewDataSource()
    // swiftlint:enable weak_delegate

    private var state: SimpleCourseList.ViewControllerState

    init(
        interactor: SimpleCourseListInteractorProtocol,
        initialState: SimpleCourseList.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)

        self.collectionViewDelegate.delegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SimpleCourseListView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doCourseListLoad(request: .init())
    }

    private func updateState(newState: SimpleCourseList.ViewControllerState) {
        self.state = newState

        switch self.state {
        case .loading:
            self.simpleCourseListView?.showLoading()
        case .result(let viewModels):
            self.simpleCourseListView?.hideLoading()

            self.collectionViewDelegate.viewModels = viewModels
            self.collectionViewDataSource.viewModels = viewModels
            self.simpleCourseListView?.updateCollectionViewData(
                delegate: self.collectionViewDelegate,
                dataSource: self.collectionViewDataSource
            )
        }
    }
}

extension SimpleCourseListViewController: SimpleCourseListViewControllerProtocol {
    func displayCourseList(viewModel: SimpleCourseList.CourseListLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

extension SimpleCourseListViewController: SimpleCourseListViewControllerDelegate {
    func itemDidSelected(viewModel: SimpleCourseListWidgetViewModel) {
        print(#function)
    }
}
