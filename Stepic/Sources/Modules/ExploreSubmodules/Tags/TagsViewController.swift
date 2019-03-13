import UIKit

protocol TagsViewControllerProtocol: class {
    func displayTags(viewModel: Tags.TagsLoad.ViewModel)
}

final class TagsViewController: UIViewController {
    private let interactor: TagsInteractorProtocol
    private var state: Tags.ViewControllerState

    lazy var tagsView = self.view as? TagsView

    init(
        interactor: TagsInteractorProtocol,
        initialState: Tags.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = TagsView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshTags()
    }

    // MARK: Requests logic

    private func refreshTags() {
        self.interactor.doTagsFetch(request: Tags.TagsLoad.Request())
    }
}

extension TagsViewController: TagsViewControllerProtocol {
    func displayTags(viewModel: Tags.TagsLoad.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.tagsView?.updateData(viewModels: data)
        default:
            break
        }
    }
}

extension TagsViewController: TagsViewDelegate {
    func tagsViewDidTagSelect(_ tagsView: TagsView, viewModel: TagViewModel) {
        self.interactor.doTagCollectionPresentation(
            request: .init(viewModelUniqueIdentifier: viewModel.uniqueIdentifier)
        )
    }
}
