import Foundation
import PromiseKit

protocol CourseSearchInteractorProtocol {
    func doCourseSearchLoad(request: CourseSearch.CourseSearchLoad.Request)
    func doCourseSearchSuggestionsLoad(request: CourseSearch.CourseSearchSuggestionsLoad.Request)
    func doSearchQueryUpdate(request: CourseSearch.SearchQueryUpdate.Request)
    func doSearch(request: CourseSearch.Search.Request)
}

final class CourseSearchInteractor: CourseSearchInteractorProtocol {
    private static let defaultSuggestionsFetchLimit = 10

    weak var moduleOutput: CourseSearchOutputProtocol?

    private let presenter: CourseSearchPresenterProtocol
    private let provider: CourseSearchProviderProtocol

    private let courseID: Course.IdType

    private var currentCourse: Course?
    private var currentSearchQueryResults: [SearchQueryResult]?
    private var currentQuery = ""

    init(
        presenter: CourseSearchPresenterProtocol,
        provider: CourseSearchProviderProtocol,
        courseID: Course.IdType
    ) {
        self.presenter = presenter
        self.provider = provider
        self.courseID = courseID
    }

    func doCourseSearchLoad(request: CourseSearch.CourseSearchLoad.Request) {
        when(
            fulfilled: self.provider.fetchCourse(),
            self.fetchSuggestions()
        ).done { course, searchQueryResults in
            self.currentCourse = course
            self.currentSearchQueryResults = searchQueryResults

            let data = CourseSearch.CourseSearchLoad.Response.Data(
                course: course,
                searchQueryResults: searchQueryResults
            )
            self.presenter.presentCourseSearchLoadResult(response: .init(result: .success(data)))
        }.catch { error in
            print("CourseSearchInteractor :: failed load content with error = \(error)")
            self.presenter.presentCourseSearchLoadResult(response: .init(result: .failure(error)))
        }
    }

    func doCourseSearchSuggestionsLoad(request: CourseSearch.CourseSearchSuggestionsLoad.Request) {
        self.fetchSuggestions().done { searchQueryResults in
            self.currentSearchQueryResults = searchQueryResults
            self.presenter.presentCourseSearchSuggestionsLoadResult(
                response: .init(searchQueryResults: searchQueryResults)
            )
        }
    }

    func doSearchQueryUpdate(request: CourseSearch.SearchQueryUpdate.Request) {
        self.currentQuery = request.query

        guard let currentSearchQueryResults = self.currentSearchQueryResults else {
            return
        }

        let trimmedQuery = request.query.trimmed()

        if trimmedQuery.isEmpty {
            self.presenter.presentSearchQueryUpdateResult(
                response: .init(query: self.currentQuery, searchQueryResults: currentSearchQueryResults)
            )
        } else {
            let results = currentSearchQueryResults.filter { $0.query.localizedCaseInsensitiveContains(trimmedQuery) }
            self.presenter.presentSearchQueryUpdateResult(
                response: .init(query: self.currentQuery, searchQueryResults: results)
            )
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

    // MARK: Private API

    private func fetchSuggestions() -> Guarantee<[SearchQueryResult]> {
        self.provider.fetchSuggestions(fetchLimit: Self.defaultSuggestionsFetchLimit)
    }
}

extension CourseSearchInteractor: CourseSearchInputProtocol {}
