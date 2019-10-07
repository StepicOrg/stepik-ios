import UIKit

final class UnsupportedQuizAssembly: Assembly {
    private let stepURLPath: String

    init(stepURLPath: String) {
        self.stepURLPath = stepURLPath
    }

    func makeModule() -> UIViewController {
        let presenter = UnsupportedQuizPresenter()
        let interactor = UnsupportedQuizInteractor(stepURLPath: self.stepURLPath, presenter: presenter)
        let viewController = UnsupportedQuizViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
