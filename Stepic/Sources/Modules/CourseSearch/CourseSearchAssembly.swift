import UIKit

final class CourseSearchAssembly: Assembly {
    private let courseID: Course.IdType

    init(courseID: Course.IdType) {
        self.courseID = courseID
    }

    func makeModule() -> UIViewController {
        let provider = CourseSearchProvider(
            courseID: self.courseID,
            searchResultsRepository: SearchResultsRepository.default,
            searchQueryResultsPersistenceService: SearchQueryResultsPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            coursesPersistenceService: CoursesPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            stepsPersistenceService: StepsPersistenceService(),
            lessonsNetworkService: LessonsNetworkService(lessonsAPI: LessonsAPI()),
            lessonsPersistenceService: LessonsPersistenceService(),
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            unitsPersistenceService: UnitsPersistenceService(),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            sectionsPersistenceService: SectionsPersistenceService(),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
            progressesPersistenceServiceProtocol: ProgressesPersistenceService(),
            usersNetworkService: UsersNetworkService(usersAPI: UsersAPI()),
            usersPersistenceService: UsersPersistenceService()
        )
        let presenter = CourseSearchPresenter()
        let interactor = CourseSearchInteractor(presenter: presenter, provider: provider, courseID: self.courseID)
        let viewController = CourseSearchViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
