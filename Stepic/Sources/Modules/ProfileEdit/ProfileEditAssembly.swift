import UIKit

final class ProfileEditAssembly: Assembly {
    // We should init assembly with profile to open
    private let profile: Profile

    init(profile: Profile) {
        self.profile = profile
    }

    func makeModule() -> UIViewController {
        let provider = ProfileEditProvider()
        let presenter = ProfileEditPresenter()
        let interactor = ProfileEditInteractor(
            presenter: presenter,
            provider: provider,
            initialProfile: self.profile
        )
        let viewController = ProfileEditViewController(interactor: interactor)

        presenter.viewController = viewController
        viewController.hidesBottomBarWhenPushed = true

        return viewController
    }
}
