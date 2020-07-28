import UIKit

protocol NewProfileSocialProfilesViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: NewProfileSocialProfiles.SomeAction.ViewModel)
}

final class NewProfileSocialProfilesViewController: UIViewController {
    private let interactor: NewProfileSocialProfilesInteractorProtocol

    init(interactor: NewProfileSocialProfilesInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileSocialProfilesView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewProfileSocialProfilesViewController: NewProfileSocialProfilesViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewProfileSocialProfiles.SomeAction.ViewModel) {}
}
