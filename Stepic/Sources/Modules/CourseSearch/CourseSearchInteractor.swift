import Foundation
import PromiseKit

protocol CourseSearchInteractorProtocol {
    func doCourseContentLoad(request: CourseSearch.CourseContentLoad.Request)
}

final class CourseSearchInteractor: CourseSearchInteractorProtocol {
    private static let defaultSuggestionsFetchLimit = 10

    weak var moduleOutput: CourseSearchOutputProtocol?

    private let presenter: CourseSearchPresenterProtocol
    private let provider: CourseSearchProviderProtocol

    private let courseID: Course.IdType

    private var currentCourse: Course?

    init(
        presenter: CourseSearchPresenterProtocol,
        provider: CourseSearchProviderProtocol,
        courseID: Course.IdType
    ) {
        self.presenter = presenter
        self.provider = provider
        self.courseID = courseID
    }

    func doCourseContentLoad(request: CourseSearch.CourseContentLoad.Request) {
        when(
            fulfilled: self.provider.fetchCourse(),
            self.provider.fetchSuggestions(fetchLimit: Self.defaultSuggestionsFetchLimit)
        ).compactMap { course, suggestions -> (Course, [SearchQueryResult])? in
            if let course = course {
                return (course, suggestions)
            }
            return nil
        }.done { course, suggestions in
            self.currentCourse = course
            print("CourseSearchInteractor :: content loaded")
            print(suggestions)
            print(course.title)
        }.catch { error in
            print("CourseSearchInteractor :: failed fetch content with error = \(error)")
        }
    }
}

extension CourseSearchInteractor: CourseSearchInputProtocol {}
