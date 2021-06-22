import UIKit

final class CourseRevenueTabPurchasesAssembly: Assembly {
    var moduleInput: CourseRevenueTabPurchasesInputProtocol?

    func makeModule() -> UIViewController {
        let provider = CourseRevenueTabPurchasesProvider(
            courseBenefitsPersistenceService: CourseBenefitsPersistenceService(),
            courseBenefitsNetworkService: CourseBenefitsNetworkService(courseBenefitsAPI: CourseBenefitsAPI())
        )
        let presenter = CourseRevenueTabPurchasesPresenter()
        let interactor = CourseRevenueTabPurchasesInteractor(presenter: presenter, provider: provider)
        let viewController = CourseRevenueTabPurchasesViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
