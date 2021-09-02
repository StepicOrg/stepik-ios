import UIKit

final class CourseSearchAssembly: Assembly {
    var moduleInput: CourseSearchInputProtocol?

    private weak var moduleOutput: CourseSearchOutputProtocol?

    private let courseID: Course.IdType

    init(courseID: Course.IdType, output: CourseSearchOutputProtocol? = nil) {
        self.courseID = courseID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseSearchProvider(
            courseID: self.courseID,
            searchResultsRepository: SearchResultsRepository.default,
            searchQueryResultsPersistenceService: SearchQueryResultsPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            coursesPersistenceService: CoursesPersistenceService()
        )
        let presenter = CourseSearchPresenter()
        let interactor = CourseSearchInteractor(presenter: presenter, provider: provider, courseID: self.courseID)
        let viewController = CourseSearchViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
