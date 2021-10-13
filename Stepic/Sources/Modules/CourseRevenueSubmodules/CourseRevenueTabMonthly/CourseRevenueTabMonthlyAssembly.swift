import UIKit

final class CourseRevenueTabMonthlyAssembly: Assembly {
    var moduleInput: CourseRevenueTabMonthlyInputProtocol?

    private weak var moduleOutput: CourseRevenueTabMonthlyOutputProtocol?

    init(output: CourseRevenueTabMonthlyOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseRevenueTabMonthlyProvider(
            courseBenefitByMonthsPersistenceService: CourseBenefitByMonthsPersistenceService(),
            courseBenefitByMonthsNetworkService: CourseBenefitByMonthsNetworkService(
                courseBenefitByMonthsAPI: CourseBenefitByMonthsAPI()
            )
        )
        let presenter = CourseRevenueTabMonthlyPresenter()
        let interactor = CourseRevenueTabMonthlyInteractor(presenter: presenter, provider: provider)
        let viewController = CourseRevenueTabMonthlyViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
