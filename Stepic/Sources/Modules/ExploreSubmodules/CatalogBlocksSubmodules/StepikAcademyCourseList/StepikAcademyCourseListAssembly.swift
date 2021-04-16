import UIKit

final class StepikAcademyCourseListAssembly: Assembly {
    private weak var moduleOutput: StepikAcademyCourseListOutputProtocol?

    private let catalogBlockID: CatalogBlock.IdType

    init(
        catalogBlockID: CatalogBlock.IdType,
        output: StepikAcademyCourseListOutputProtocol? = nil
    ) {
        self.catalogBlockID = catalogBlockID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = StepikAcademyCourseListProvider(catalogBlocksRepository: CatalogBlocksRepository.default)
        let presenter = StepikAcademyCourseListPresenter()
        let interactor = StepikAcademyCourseListInteractor(
            catalogBlockID: self.catalogBlockID,
            presenter: presenter,
            provider: provider
        )
        let viewController = StepikAcademyCourseListViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
