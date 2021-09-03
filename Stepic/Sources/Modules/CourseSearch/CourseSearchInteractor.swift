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

    private let presenter: CourseSearchPresenterProtocol
    private let provider: CourseSearchProviderProtocol

    private let courseID: Course.IdType

    private var currentCourse: Course?
    private var currentSuggestions: [SearchQueryResult]?
    @Trimmed
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
        ).done { course, suggestions in
            self.currentCourse = course
            self.currentSuggestions = suggestions

            let data = CourseSearch.CourseSearchLoad.Response.Data(course: course, suggestions: suggestions)
            self.presenter.presentCourseSearchLoadResult(response: .init(result: .success(data)))
        }.catch { error in
            print("CourseSearchInteractor :: failed \(#function) with error = \(error)")
            self.presenter.presentCourseSearchLoadResult(response: .init(result: .failure(error)))
        }
    }

    func doCourseSearchSuggestionsLoad(request: CourseSearch.CourseSearchSuggestionsLoad.Request) {
        self.fetchSuggestions().done { suggestions in
            self.currentSuggestions = suggestions
            self.presenter.presentCourseSearchSuggestionsLoadResult(response: .init(suggestions: suggestions))
        }
    }

    func doSearchQueryUpdate(request: CourseSearch.SearchQueryUpdate.Request) {
        self.currentQuery = request.query

        guard let currentSuggestions = self.currentSuggestions else {
            return
        }

        if self.currentQuery.isEmpty {
            self.presenter.presentSearchQueryUpdateResult(
                response: .init(query: self.currentQuery, suggestions: currentSuggestions)
            )
        } else {
            let suggestions = currentSuggestions.filter { $0.query.localizedCaseInsensitiveContains(self.currentQuery) }
            self.presenter.presentSearchQueryUpdateResult(
                response: .init(query: self.currentQuery, suggestions: suggestions)
            )
        }
    }

    func doSearch(request: CourseSearch.Search.Request) {
        switch request.source {
        case .searchQuery:
            guard !self.currentQuery.isEmpty else {
                return
            }

            self.provider.searchInCourseRemotely(query: self.currentQuery, page: 1).done { searchResults, meta in
                print(searchResults)
                print(meta)
            }.catch { error in
                print("CourseSearchInteractor :: failed search with error = \(error)")
            }
        case .suggestion(let viewModelUniqueIdentifier):
            guard let targetSearchQueryResult = self.currentSuggestions?.first(
                where: { $0.id == viewModelUniqueIdentifier }
            ) else {
                return
            }

            print(targetSearchQueryResult)
        }
    }

    // MARK: Private API

    private func fetchSuggestions() -> Guarantee<[SearchQueryResult]> {
        self.provider.fetchSuggestions(fetchLimit: Self.defaultSuggestionsFetchLimit)
    }
}
