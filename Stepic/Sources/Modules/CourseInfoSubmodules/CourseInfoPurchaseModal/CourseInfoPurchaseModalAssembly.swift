import UIKit

final class CourseInfoPurchaseModalAssembly: Assembly {
    var moduleInput: CourseInfoPurchaseModalInputProtocol?

    private weak var moduleOutput: CourseInfoPurchaseModalOutputProtocol?

    init(output: CourseInfoPurchaseModalOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseInfoPurchaseModalProvider()
        let presenter = CourseInfoPurchaseModalPresenter()
        let interactor = CourseInfoPurchaseModalInteractor(presenter: presenter, provider: provider)
        let viewController = CourseInfoPurchaseModalViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
