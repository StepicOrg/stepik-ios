import UIKit

protocol NewProfileActivityViewControllerProtocol: AnyObject {
    func displayUserActivity(viewModel: NewProfileActivity.ActivityLoad.ViewModel)
}

final class NewProfileActivityViewController: UIViewController {
    private let interactor: NewProfileActivityInteractorProtocol

    var newProfileActivityView: NewProfileActivityView? { self.view as? NewProfileActivityView }

    init(interactor: NewProfileActivityInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileActivityView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewProfileActivityViewController: NewProfileActivityViewControllerProtocol {
    func displayUserActivity(viewModel: NewProfileActivity.ActivityLoad.ViewModel) {
        self.newProfileActivityView?.configure(viewModel: viewModel.viewModel)
    }
}
