import UIKit

final class StepikAcademyCourseListAssembly: Assembly {
    private weak var moduleOutput: StepikAcademyCourseListOutputProtocol?

    init(output: StepikAcademyCourseListOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = StepikAcademyCourseListProvider()
        let presenter = StepikAcademyCourseListPresenter()
        let interactor = StepikAcademyCourseListInteractor(presenter: presenter, provider: provider)
        let viewController = StepikAcademyCourseListViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
