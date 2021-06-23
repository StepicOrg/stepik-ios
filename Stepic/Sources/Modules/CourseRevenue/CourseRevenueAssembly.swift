import UIKit

final class CourseRevenueAssembly: Assembly {
    private let courseID: Course.IdType
    private let initialTab: CourseRevenue.Tab

    init(
        courseID: Course.IdType,
        initialTab: CourseRevenue.Tab = .purchasesAndRefunds
    ) {
        self.courseID = courseID
        self.initialTab = initialTab
    }

    func makeModule() -> UIViewController {
        let provider = CourseRevenueProvider(
            courseID: self.courseID,
            coursesPersistenceService: CoursesPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            courseBenefitSummariesPersistenceService: CourseBenefitSummariesPersistenceService(),
            courseBenefitSummariesNetworkService: CourseBenefitSummariesNetworkService(
                courseBenefitSummariesAPI: CourseBenefitSummariesAPI()
            )
        )
        let presenter = CourseRevenuePresenter()
        let interactor = CourseRevenueInteractor(
            courseID: self.courseID,
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared
        )
        let viewController = CourseRevenueViewController(
            interactor: interactor,
            availableTabs: [.purchasesAndRefunds],
            initialTab: self.initialTab
        )

        presenter.viewController = viewController

        return viewController
    }
}
