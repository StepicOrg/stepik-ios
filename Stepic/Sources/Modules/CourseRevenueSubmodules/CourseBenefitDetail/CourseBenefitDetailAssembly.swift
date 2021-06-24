import UIKit

final class CourseBenefitDetailAssembly: Assembly {
    private let courseBenefitID: CourseBenefit.IdType

    init(courseBenefitID: CourseBenefit.IdType) {
        self.courseBenefitID = courseBenefitID
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

        return viewController
    }
}
