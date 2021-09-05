import UIKit

protocol CourseSearchPresenterProtocol {
    func presentCourseSearchLoadResult(response: CourseSearch.CourseSearchLoad.Response)
    func presentCourseSearchSuggestionsLoadResult(response: CourseSearch.CourseSearchSuggestionsLoad.Response)
    func presentSearchQueryUpdateResult(response: CourseSearch.SearchQueryUpdate.Response)
    func presentSearchResults(response: CourseSearch.Search.Response)
    func presentCommentUser(response: CourseSearch.CommentUserPresentation.Response)
    func presentLoadingState(response: CourseSearch.LoadingStatePresentation.Response)
}

final class CourseSearchPresenter: CourseSearchPresenterProtocol {
    weak var viewController: CourseSearchViewControllerProtocol?

    func presentCourseSearchLoadResult(response: CourseSearch.CourseSearchLoad.Response) {
        switch response.result {
        case .success(let data):
            let placeholderText = String(
                format: NSLocalizedString("CourseSearchBarPlaceholder", comment: ""),
                arguments: [data.course?.title ?? ""]
            ).trimmed()

            let suggestions = data.suggestions.map(self.makeSuggestionViewModel(_:))

            self.viewController?.displayCourseSearchLoadResult(
                viewModel: .init(placeholderText: placeholderText, suggestions: suggestions)
            )
        case .failure:
            break
        }
    }

    func presentCourseSearchSuggestionsLoadResult(response: CourseSearch.CourseSearchSuggestionsLoad.Response) {
        let suggestions = response.suggestions.map(self.makeSuggestionViewModel(_:))
        self.viewController?.displayCourseSearchSuggestionsLoadResult(viewModel: .init(suggestions: suggestions))
    }

    func presentSearchQueryUpdateResult(response: CourseSearch.SearchQueryUpdate.Response) {
        let suggestions = response.suggestions.map(self.makeSuggestionViewModel(_:))
        self.viewController?.displaySearchQueryUpdateResult(
            viewModel: .init(query: response.query, suggestions: suggestions)
        )
    }

    func presentSearchResults(response: CourseSearch.Search.Response) {
        switch response.result {
        case .success(let data):
            let searchResults = data.searchResults.map { searchResult -> CourseSearchResultViewModel in
                let title: String = {
                    let lessonTitle = searchResult.lessonTitle ?? ""

                    if searchResult.isStep || searchResult.isComment {
                        return "\(lessonTitle) - Шаг \(searchResult.stepPosition ?? 0)"
                    }

                    return lessonTitle
                }()

                let coverImageURL: URL? = {
                    if let lessonCoverURL = searchResult.lessonCoverURL {
                        return URL(string: lessonCoverURL)
                    }
                    return nil
                }()

                let commentViewModel: CourseSearchResultViewModel.Comment? = {
                    guard searchResult.isComment else {
                        return nil
                    }

                    let avatarImageURL: URL?
                    let username: String

                    if let commentUserInfo = searchResult.commentUserInfo {
                        avatarImageURL = URL(string: commentUserInfo.avatarURL)
                        username = FormatterHelper.username(commentUserInfo)
                    } else {
                        avatarImageURL = nil
                        username = "User \(searchResult.commentUserID ??? "n/a")"
                    }

                    return CourseSearchResultViewModel.Comment(
                        avatarImageURL: avatarImageURL,
                        username: username,
                        text: searchResult.commentText ?? ""
                    )
                }()

                return CourseSearchResultViewModel(
                    uniqueIdentifier: "\(searchResult.id)",
                    title: title,
                    coverImageURL: coverImageURL,
                    likesCount: 771,
                    learnersLabelText: "270K",
                    progressLabelText: "7/20 баллов",
                    timeToCompleteLabelText: "1 ч",
                    comment: commentViewModel
                )
            }

            let resultData = CourseSearch.SearchResultData(
                searchResults: searchResults,
                hasNextPage: data.hasNextPage
            )

            self.viewController?.displaySearchResults(viewModel: .init(state: .result(data: resultData)))
        case .failure:
            self.viewController?.displaySearchResults(viewModel: .init(state: .error))
        }
    }

    func presentCommentUser(response: CourseSearch.CommentUserPresentation.Response) {
        self.viewController?.displayCommentUser(viewModel: .init(userID: response.userID))
    }

    func presentLoadingState(response: CourseSearch.LoadingStatePresentation.Response) {
        self.viewController?.displayLoadingState(viewModel: .init())
    }

    // MARK: Private API

    private func makeSuggestionViewModel(_ searchQueryResult: SearchQueryResult) -> CourseSearchSuggestionViewModel {
        .init(uniqueIdentifier: searchQueryResult.id, title: searchQueryResult.query)
    }
}
