import UIKit

protocol SimpleCourseListViewControllerProtocol: AnyObject {
    func displayCourseList(viewModel: SimpleCourseList.CourseListLoad.ViewModel)
}

protocol SimpleCourseListViewControllerDelegate: AnyObject {
    func itemDidSelected(viewModel: SimpleCourseListWidgetViewModel)
}

final class SimpleCourseListViewController: UIViewController {
    private let interactor: SimpleCourseListInteractorProtocol
    private let layoutType: SimpleCourseList.LayoutType

    var simpleCourseListView: SimpleCourseListViewProtocol? { self.view as? SimpleCourseListViewProtocol }

    // swiftlint:disable weak_delegate
    private let collectionViewDelegate = SimpleCourseListCollectionViewDelegate()
    private let collectionViewDataSource = SimpleCourseListCollectionViewDataSource()
    // swiftlint:enable weak_delegate

    private var state: SimpleCourseList.ViewControllerState

    init(
        interactor: SimpleCourseListInteractorProtocol,
        layoutType: SimpleCourseList.LayoutType = .default,
        initialState: SimpleCourseList.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.layoutType = layoutType
        self.state = initialState

        super.init(nibName: nil, bundle: nil)

        self.collectionViewDelegate.delegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        switch self.layoutType {
        case .default:
            self.view = DefaultSimpleCourseListView()
        case .grid:
            self.view = GridSimpleCourseListView()
        }
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
        self.interactor.doCourseListPresentation(request: .init(uniqueIdentifier: viewModel.uniqueIdentifier))
    }
}
