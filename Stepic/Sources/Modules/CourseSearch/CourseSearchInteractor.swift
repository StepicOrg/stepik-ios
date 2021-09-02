import Foundation
import PromiseKit

protocol CourseSearchInteractorProtocol {
    func doCourseContentLoad(request: CourseSearch.CourseContentLoad.Request)
    func doSearch(request: CourseSearch.Search.Request)
}

final class CourseSearchInteractor: CourseSearchInteractorProtocol {
    private static let defaultSuggestionsFetchLimit = 10

    weak var moduleOutput: CourseSearchOutputProtocol?

    private let presenter: CourseSearchPresenterProtocol
    private let provider: CourseSearchProviderProtocol

    private let courseID: Course.IdType

    private var currentCourse: Course?
    private var currentSearchQueryResults = [SearchQueryResult]()

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
        print("CourseSearchInteractor :: loading content")
        when(
            fulfilled: self.provider.fetchCourse(),
            self.provider.fetchSuggestions(fetchLimit: Self.defaultSuggestionsFetchLimit)
        ).compactMap { course, suggestions -> (Course, [SearchQueryResult])? in
            if let course = course {
                return (course, suggestions)
            }
            return nil
        }.done { course, suggestions in
            print("CourseSearchInteractor :: content loaded")

            self.currentCourse = course
            self.currentSearchQueryResults = suggestions

            self.presenter.presentCourseContent(
                response: .init(result: .success(.init(course: course, searchQueryResults: suggestions)))
            )
        }.catch { error in
            print("CourseSearchInteractor :: failed load content with error = \(error)")
            self.presenter.presentCourseContent(response: .init(result: .failure(error)))
        }
    }

    func doSearch(request: CourseSearch.Search.Request) {
        self.provider.searchInCourseRemotely(query: request.query, page: 1).done { searchResults, meta in
            print(searchResults)
            print(meta)
        }.catch { error in
            print("CourseSearchInteractor :: failed search with error = \(error)")
        }
    }
}

extension CourseSearchInteractor: CourseSearchInputProtocol {}
