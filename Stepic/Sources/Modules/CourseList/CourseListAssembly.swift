import UIKit

class CourseListAssembly: Assembly {
    let type: CourseListType
    let colorMode: CourseListColorMode
    let cardStyle: CourseListCardStyle
    let gridSize: CourseListGridSize

    private let courseViewSource: AnalyticsEvent.CourseViewSource

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
        cardStyle: CourseListCardStyle,
        gridSize: CourseListGridSize,
        courseViewSource: AnalyticsEvent.CourseViewSource,
        output: CourseListOutputProtocol? = nil
    ) {
        self.type = type
        self.colorMode = colorMode
        self.cardStyle = cardStyle
        self.gridSize = gridSize
        self.courseViewSource = courseViewSource
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
            ),
            courseListsPersistenceService: CourseListsPersistenceService(),
            iapService: IAPService.shared
        )

        let dataBackUpdateService = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )
        let courseListDataBackUpdateService = CourseListDataBackUpdateService(
            courseListType: self.type,
            dataBackUpdateService: dataBackUpdateService
        )

        let interactor = CourseListInteractor(
            presenter: presenter,
            provider: provider,
            adaptiveStorageManager: AdaptiveStorageManager(),
            courseSubscriber: CourseSubscriber(),
            userAccountService: UserAccountService(),
            personalDeadlinesService: PersonalDeadlinesService(),
            wishlistService: WishlistService.default,
            courseListDataBackUpdateService: courseListDataBackUpdateService,
            analytics: StepikAnalytics.shared,
            courseViewSource: self.courseViewSource
        )
        self.moduleInput = interactor

        let controller = self.makeViewController(interactor: interactor)
        presenter.viewController = controller
        interactor.moduleOutput = self.moduleOutput
        return controller
    }
}

final class HorizontalCourseListAssembly: CourseListAssembly {
    private let maxNumberOfDisplayedCourses: Int?

    override fileprivate func makeViewController(
        interactor: CourseListInteractorProtocol
    ) -> (UIViewController & CourseListViewControllerProtocol) {
        HorizontalCourseListViewController(
            interactor: interactor,
            colorMode: self.colorMode,
            cardStyle: self.cardStyle,
            gridSize: self.gridSize,
            maxNumberOfDisplayedCourses: self.maxNumberOfDisplayedCourses
        )
    }

    init(
        type: CourseListType,
        colorMode: CourseListColorMode,
        cardStyle: CourseListCardStyle = .default,
        gridSize: CourseListGridSize = .default,
        courseViewSource: AnalyticsEvent.CourseViewSource,
        maxNumberOfDisplayedCourses: Int? = nil,
        output: CourseListOutputProtocol? = nil
    ) {
        self.maxNumberOfDisplayedCourses = maxNumberOfDisplayedCourses
        super.init(
            type: type,
            colorMode: colorMode,
            cardStyle: cardStyle,
            gridSize: gridSize,
            courseViewSource: courseViewSource,
            output: output
        )
    }
}

final class VerticalCourseListAssembly: CourseListAssembly {
    private let presentationDescription: CourseList.PresentationDescription?

    override fileprivate func makeViewController(
        interactor: CourseListInteractorProtocol
    ) -> (UIViewController & CourseListViewControllerProtocol) {
        VerticalCourseListViewController(
            interactor: interactor,
            colorMode: self.colorMode,
            cardStyle: self.cardStyle,
            gridSize: self.gridSize,
            presentationDescription: self.presentationDescription
        )
    }

    init(
        type: CourseListType,
        colorMode: CourseListColorMode,
        cardStyle: CourseListCardStyle = .default,
        gridSize: CourseListGridSize = .default,
        courseViewSource: AnalyticsEvent.CourseViewSource,
        presentationDescription: CourseList.PresentationDescription?,
        output: CourseListOutputProtocol? = nil
    ) {
        self.presentationDescription = presentationDescription
        super.init(
            type: type,
            colorMode: colorMode,
            cardStyle: cardStyle,
            gridSize: gridSize,
            courseViewSource: courseViewSource,
            output: output
        )
    }
}
