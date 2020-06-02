import UIKit

final class NewProfileDetailsAssembly: Assembly {
    func makeModule() -> UIViewController {
        NewProfileDetailsViewController()
    }
}

final class NewProfileDetailsViewController: UIViewController {
    lazy var newProfileDetailsView = self.view as? NewProfileDetailsView

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileDetailsView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
}

extension NewProfileDetailsViewController: NewProfileSubmoduleProtocol {
    func update(with user: User, isOnline: Bool) {
        self.newProfileDetailsView?.text = user.details
    }
}

extension NewProfileDetailsViewController: NewProfileDetailsViewDelegate {
    func newProfileDetailsView(_ view: NewProfileDetailsView, didOpenURL url: URL) {
        WebControllerManager.shared.presentWebControllerWithURL(
            url,
            inController: self,
            withKey: .externalLink,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }
}
