import UIKit

protocol StepikAcademyCourseListViewControllerProtocol: AnyObject {
    func displayCourseList(viewModel: StepikAcademyCourseList.CourseListLoad.ViewModel)
}

protocol StepikAcademyCourseListViewControllerDelegate: AnyObject {
    func itemDidSelected(viewModel: StepikAcademyCourseListWidgetViewModel)
}

final class StepikAcademyCourseListViewController: UIViewController {
    private let interactor: StepikAcademyCourseListInteractorProtocol

    var stepikAcademyCourseListView: StepikAcademyCourseListView? { self.view as? StepikAcademyCourseListView }

    // swiftlint:disable weak_delegate
    private let collectionViewDelegate = StepikAcademyCourseListCollectionViewDelegate()
    private let collectionViewDataSource = StepikAcademyCourseListCollectionViewDataSource()
    // swiftlint:enable weak_delegate

    private var state: StepikAcademyCourseList.ViewControllerState

    init(
        interactor: StepikAcademyCourseListInteractorProtocol,
        initialState: StepikAcademyCourseList.ViewControllerState = .loading
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
        let view = StepikAcademyCourseListView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doCourseListLoad(request: .init())
    }

    private func updateState(newState: StepikAcademyCourseList.ViewControllerState) {
        self.state = newState

        switch self.state {
        case .loading:
            self.stepikAcademyCourseListView?.showLoading()
        case .result(let viewModels):
            self.stepikAcademyCourseListView?.hideLoading()

            self.collectionViewDelegate.viewModels = viewModels
            self.collectionViewDataSource.viewModels = viewModels
            self.stepikAcademyCourseListView?.updateCollectionViewData(
                delegate: self.collectionViewDelegate,
                dataSource: self.collectionViewDataSource
            )
        }
    }
}

extension StepikAcademyCourseListViewController: StepikAcademyCourseListViewControllerProtocol {
    func displayCourseList(viewModel: StepikAcademyCourseList.CourseListLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

extension StepikAcademyCourseListViewController: StepikAcademyCourseListViewControllerDelegate {
    func itemDidSelected(viewModel: StepikAcademyCourseListWidgetViewModel) {
        self.interactor.doSpecializationPresentation(request: .init(uniqueIdentifier: viewModel.uniqueIdentifier))
    }
}
