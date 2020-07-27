import SVProgressHUD
import UIKit

final class NewProfileDetailsAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let viewController = NewProfileDetailsViewController()
        self.moduleInput = viewController
        return viewController
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
        DispatchQueue.main.async {
            let sharingURLString = "\(StepikApplicationsInfo.stepikURL)/users/\(userID)"
            UIPasteboard.general.string = sharingURLString
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Copied", comment: ""))
        }
    }
}
