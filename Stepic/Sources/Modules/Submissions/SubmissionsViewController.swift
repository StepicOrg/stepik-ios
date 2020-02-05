import UIKit

protocol SubmissionsViewControllerProtocol: AnyObject {
    func displaySubmissions(viewModel: Submissions.SubmissionsLoad.ViewModel)
}

final class SubmissionsViewController: UIViewController {
    private let interactor: SubmissionsInteractorProtocol

    init(interactor: SubmissionsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SubmissionsView(frame: UIScreen.main.bounds)
        self.view = view
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.interactor.doSubmissionsLoad(request: .init())
    }
}

extension SubmissionsViewController: SubmissionsViewControllerProtocol {
    func displaySubmissions(viewModel: Submissions.SubmissionsLoad.ViewModel) {
        print(viewModel)
    }
}
