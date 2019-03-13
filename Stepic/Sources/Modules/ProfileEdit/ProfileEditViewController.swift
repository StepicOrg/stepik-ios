import UIKit

protocol ProfileEditViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: ProfileEdit.SomeAction.ViewModel)
}

final class ProfileEditViewController: UIViewController {
    private let interactor: ProfileEditInteractorProtocol

    init(interactor: ProfileEditInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfileEditView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension ProfileEditViewController: ProfileEditViewControllerProtocol {
    func displaySomeActionResult(viewModel: ProfileEdit.SomeAction.ViewModel) { }
}