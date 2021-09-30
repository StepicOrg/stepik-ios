import Foundation
import PromiseKit

protocol CourseSearchInteractorProtocol {
    func doCourseSearchLoad(request: CourseSearch.CourseSearchLoad.Request)
    func doCourseSearchSuggestionsLoad(request: CourseSearch.CourseSearchSuggestionsLoad.Request)

    func doSearchQueryUpdate(request: CourseSearch.SearchQueryUpdate.Request)
    func doSearchResultsLoad(request: CourseSearch.SearchResultsLoad.Request)
    func doNextSearchResultsLoad(request: CourseSearch.NextSearchResultsLoad.Request)

    func doCommentUserPresentation(request: CourseSearch.CommentUserPresentation.Request)
    func doCommentDiscussionPresentation(request: CourseSearch.CommentDiscussionPresentation.Request)

    func doSearchResultPresentation(request: CourseSearch.SearchResultPresentation.Request)
}

final class CourseSearchInteractor: CourseSearchInteractorProtocol {
    private static let defaultSuggestionsFetchLimit = 10

    private let presenter: CourseSearchPresenterProtocol
    private let provider: CourseSearchProviderProtocol

    private let courseID: Course.IdType

    private var currentCourse: Course?
    private var currentSuggestions: [SearchQueryResult]?
    private var currentSelectedSuggestion: SearchQueryResult?
    @Trimmed
    private var currentQuery = ""

    private var currentSearchResults: [SearchResultPlainObject]?
    private var paginationState = PaginationState(page: 1, hasNext: false)

    private let analytics: Analytics
    private var shouldOpenedAnalyticsEventSend = true

    init(
        presenter: CourseSearchPresenterProtocol,
        provider: CourseSearchProviderProtocol,
        courseID: Course.IdType,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
        self.courseID = courseID
        self.analytics = analytics
    }

    func doCourseSearchLoad(request: CourseSearch.CourseSearchLoad.Request) {
        when(
            fulfilled: self.provider.fetchCourse(),
            self.fetchSuggestions()
        ).done { course, suggestions in
            self.currentCourse = course
            self.currentSuggestions = suggestions

            if self.shouldOpenedAnalyticsEventSend {
                self.shouldOpenedAnalyticsEventSend = false
                self.analytics.send(
                    .courseContentSearchScreenOpened(id: self.courseID, title: self.currentCourse?.title)
                )
            }

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

    func doSearchResultsLoad(request: CourseSearch.SearchResultsLoad.Request) {
        defer {
            self.analytics.send(
                .courseContentSearched(
                    id: self.courseID,
                    title: self.currentCourse?.title,
                    query: self.currentQuery,
                    suggestion: self.currentSelectedSuggestion?.query
                )
            )
        }

        self.currentSelectedSuggestion = nil

        switch request.source {
        case .searchQuery:
            guard !self.currentQuery.isEmpty else {
                return
            }

            self.presenter.presentLoadingState(response: .init())

            self.searchInCourse(query: self.currentQuery, page: 1).done { data in
                self.currentSearchResults = data.searchResults
                self.paginationState = PaginationState(page: 1, hasNext: data.hasNextPage)

                self.presenter.presentSearchResults(response: .init(result: .success(data)))
            }.catch { error in
                print("CourseSearchInteractor :: failed search with error = \(error)")
                self.presenter.presentSearchResults(response: .init(result: .failure(error)))
            }
        case .suggestion(let viewModelUniqueIdentifier):
            guard let targetSearchQueryResult = self.currentSuggestions?.first(
                where: { $0.id == viewModelUniqueIdentifier }
            ) else {
                return
            }

            self.currentSelectedSuggestion = targetSearchQueryResult

            let data = CourseSearch.SearchResponseData(
                course: self.currentCourse,
                searchResults: targetSearchQueryResult.searchResults.map(\.plainObject),
                hasNextPage: false
            )

            self.currentSearchResults = data.searchResults
            self.paginationState = PaginationState(page: 1, hasNext: false)

            self.presenter.presentSearchResults(response: .init(result: .success(data)))
        }
    }

    func doNextSearchResultsLoad(request: CourseSearch.NextSearchResultsLoad.Request) {
        guard self.paginationState.hasNext && !self.currentQuery.isEmpty else {
            return
        }

        let nextPageIndex = self.paginationState.page + 1
        print("CourseSearchInteractor :: load next page, page = \(nextPageIndex)")

        self.searchInCourse(query: self.currentQuery, page: nextPageIndex).done { data in
            self.currentSearchResults?.append(contentsOf: data.searchResults)
            self.paginationState = PaginationState(page: nextPageIndex, hasNext: data.hasNextPage)

            self.presenter.presentNextSearchResults(response: .init(result: .success(data)))
        }.catch { error in
            print("CourseSearchInteractor :: failed load next page with error = \(error)")
            self.presenter.presentNextSearchResults(response: .init(result: .failure(error)))
        }
    }

    func doCommentUserPresentation(request: CourseSearch.CommentUserPresentation.Request) {
        guard let target = self.currentSearchResults?.first(where: { "\($0.id)" == request.viewModelUniqueIdentifier }),
              let commentUserID = target.commentUserID else {
            return
        }

        self.analytics.send(
            .courseContentSearchResultClicked(
                id: self.courseID,
                title: self.currentCourse?.title,
                query: self.currentQuery,
                suggestion: self.currentSelectedSuggestion?.query,
                type: .user,
                stepID: target.stepID
            )
        )

        self.presenter.presentCommentUser(response: .init(userID: commentUserID))
    }

    func doCommentDiscussionPresentation(request: CourseSearch.CommentDiscussionPresentation.Request) {
        guard let targetSearchResult = self.currentSearchResults?.first(
            where: { "\($0.id)" == request.viewModelUniqueIdentifier }
        ), targetSearchResult.isComment else {
            return
        }

        self.analytics.send(
            .courseContentSearchResultClicked(
                id: self.courseID,
                title: self.currentCourse?.title,
                query: self.currentQuery,
                suggestion: self.currentSelectedSuggestion?.query,
                type: .comment,
                stepID: targetSearchResult.stepID
            )
        )

        self.presenter.presentCommentDiscussion(response: .init(searchResult: targetSearchResult))
    }

    func doSearchResultPresentation(request: CourseSearch.SearchResultPresentation.Request) {
        guard let targetSearchResult = self.currentSearchResults?.first(
            where: { "\($0.id)" == request.viewModelUniqueIdentifier }
        ), let lessonID = targetSearchResult.lessonID else {
            return
        }

        self.analytics.send(
            .courseContentSearchResultClicked(
                id: self.courseID,
                title: self.currentCourse?.title,
                query: self.currentQuery,
                suggestion: self.currentSelectedSuggestion?.query,
                type: .step,
                stepID: targetSearchResult.stepID
            )
        )

        if targetSearchResult.isLesson {
            self.presenter.presentLesson(response: .init(lessonID: lessonID, stepID: nil))
        } else if let stepID = targetSearchResult.stepID {
            self.presenter.presentLesson(response: .init(lessonID: lessonID, stepID: stepID))
        }
    }

    // MARK: Private API

    private func searchInCourse(query: String, page: Int) -> Promise<CourseSearch.SearchResponseData> {
        self.provider.searchInCourse(
            query: query,
            page: page
        ).then { searchResults, meta -> Promise<CourseSearch.SearchResponseData> in
            let data = CourseSearch.SearchResponseData(
                course: self.currentCourse,
                searchResults: searchResults,
                hasNextPage: meta.hasNext
            )
            return .value(data)
        }
    }

    private func fetchSuggestions() -> Guarantee<[SearchQueryResult]> {
        self.provider.fetchSuggestions(fetchLimit: Self.defaultSuggestionsFetchLimit)
    }
}
