import SVProgressHUD
import UIKit

final class NewProfileDetailsAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let viewController = NewProfileDetailsViewController(urlFactory: StepikURLFactory())
        self.moduleInput = viewController
        return viewController
    }
}

final class NewProfileDetailsViewController: UIViewController {
    lazy var newProfileDetailsView = self.view as? NewProfileDetailsView

    private let urlFactory: StepikURLFactory

    init(urlFactory: StepikURLFactory) {
        self.urlFactory = urlFactory
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
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {
        self.newProfileDetailsView?.configure(
            viewModel: .init(userID: user.id, profileDetailsText: user.details, isOrganization: user.isOrganization)
        )
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

    func newProfileDetailsView(_ view: NewProfileDetailsView, didSelectUserID userID: User.IdType) {
        guard let userURL = self.urlFactory.makeUser(id: userID) else {
            return
        }

        DispatchQueue.main.async {
            UIPasteboard.general.string = userURL.absoluteString
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Copied", comment: ""))
        }
    }
}
