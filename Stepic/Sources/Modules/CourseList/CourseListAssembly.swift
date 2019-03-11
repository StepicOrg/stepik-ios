import UIKit

class CourseListAssembly: Assembly {
    let type: CourseListType
    let colorMode: CourseListColorMode

    // Input
    var moduleInput: CourseListInputProtocol?

    // Output
    private weak var moduleOutput: CourseListOutputProtocol?

    // swiftlint:disable:next unavailable_function
    fileprivate func makeViewController(
        interactor: CourseListInteractorProtocol
    ) -> (UIViewController & CourseListViewControllerProtocol) {
        fatalError("Property should be overridden in subclass")
    }

    fileprivate init(
        type: CourseListType,
        colorMode: CourseListColorMode,
        output: CourseListOutputProtocol? = nil
    ) {
        self.type = type
        self.colorMode = colorMode
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let servicesFactory = CourseListServicesFactory(
            type: self.type,
            coursesAPI: CoursesAPI(),
            userCoursesAPI: UserCoursesAPI(),
            searchResultsAPI: SearchResultsAPI()
        )

        let presenter = CourseListPresenter()
        let provider = CourseListProvider(
            type: self.type,
            networkService: servicesFactory.makeNetworkService(),
            persistenceService: servicesFactory.makePersistenceService(),
            progressesNetworkService: ProgressesNetworkService(
                progressesAPI: ProgressesAPI()
            ),
            reviewSummariesNetworkService: CourseReviewSummariesNetworkService(
                courseReviewSummariesAPI: CourseReviewSummariesAPI()
            )
        )

        let dataBackUpdateService = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )

        let interactor = CourseListInteractor(
            presenter: presenter,
            provider: provider,
            adaptiveStorageManager: AdaptiveStorageManager(),
            courseSubscriber: CourseSubscriber(),
            userAccountService: UserAccountService(),
            personalDeadlinesService: PersonalDeadlinesService(),
            dataBackUpdateService: dataBackUpdateService
        )
        self.moduleInput = interactor

        let controller = self.makeViewController(interactor: interactor)
        presenter.viewController = controller
        interactor.moduleOutput = self.moduleOutput
        return controller
    }
}

final class HorizontalCourseListAssembly: CourseListAssembly {
    static let defaultMaxNumberOfDisplayedCourses = 14

    private let maxNumberOfDisplayedCourses: Int?

    override fileprivate func makeViewController(
        interactor: CourseListInteractorProtocol
    ) -> (UIViewController & CourseListViewControllerProtocol) {
        return HorizontalCourseListViewController(
            interactor: interactor,
            colorMode: self.colorMode,
            maxNumberOfDisplayedCourses: self.maxNumberOfDisplayedCourses
        )
    }

    init(
        type: CourseListType,
        colorMode: CourseListColorMode,
        maxNumberOfDisplayedCourses: Int? = HorizontalCourseListAssembly.defaultMaxNumberOfDisplayedCourses,
        output: CourseListOutputProtocol? = nil
    ) {
        self.maxNumberOfDisplayedCourses = maxNumberOfDisplayedCourses
        super.init(
            type: type,
            colorMode: colorMode,
            output: output
        )
    }
}

final class VerticalCourseListAssembly: CourseListAssembly {
    private let presentationDescription: CourseList.PresentationDescription?

    override fileprivate func makeViewController(
        interactor: CourseListInteractorProtocol
    ) -> (UIViewController & CourseListViewControllerProtocol) {
        return VerticalCourseListViewController(
            interactor: interactor,
            colorMode: self.colorMode,
            presentationDescription: self.presentationDescription
        )
    }

    init(
        type: CourseListType,
        colorMode: CourseListColorMode,
        presentationDescription: CourseList.PresentationDescription?,
        output: CourseListOutputProtocol? = nil
    ) {
        self.presentationDescription = presentationDescription
        super.init(
            type: type,
            colorMode: colorMode,
            output: output
        )
    }
}
