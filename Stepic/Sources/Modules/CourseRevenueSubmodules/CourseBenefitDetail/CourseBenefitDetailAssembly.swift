import UIKit

final class CourseBenefitDetailAssembly: Assembly {
    var moduleInput: CourseBenefitDetailInputProtocol?

    private weak var moduleOutput: CourseBenefitDetailOutputProtocol?

    init(output: CourseBenefitDetailOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseBenefitDetailProvider()
        let presenter = CourseBenefitDetailPresenter()
        let interactor = CourseBenefitDetailInteractor(presenter: presenter, provider: provider)
        let viewController = CourseBenefitDetailViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
