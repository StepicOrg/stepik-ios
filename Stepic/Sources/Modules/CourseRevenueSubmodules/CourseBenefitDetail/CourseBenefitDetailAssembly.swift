import UIKit

final class CourseBenefitDetailAssembly: Assembly {
    private let courseBenefitID: CourseBenefit.IdType

    private weak var moduleOutput: CourseBenefitDetailOutputProtocol?

    init(
        courseBenefitID: CourseBenefit.IdType,
        moduleOutput: CourseBenefitDetailOutputProtocol? = nil
    ) {
        self.courseBenefitID = courseBenefitID
        self.moduleOutput = moduleOutput
    }

    func makeModule() -> UIViewController {
        let provider = CourseBenefitDetailProvider(
            courseBenefitID: self.courseBenefitID,
            courseBenefitsPersistenceService: CourseBenefitsPersistenceService(),
            courseBenefitsNetworkService: CourseBenefitsNetworkService(courseBenefitsAPI: CourseBenefitsAPI())
        )
        let presenter = CourseBenefitDetailPresenter()
        let interactor = CourseBenefitDetailInteractor(
            presenter: presenter,
            provider: provider,
            courseBenefitID: self.courseBenefitID
        )
        let viewController = CourseBenefitDetailViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
