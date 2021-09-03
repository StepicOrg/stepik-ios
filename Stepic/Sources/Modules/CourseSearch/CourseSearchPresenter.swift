import UIKit

protocol CourseSearchPresenterProtocol {
    func presentCourseSearchLoadResult(response: CourseSearch.CourseSearchLoad.Response)
    func presentCourseSearchSuggestionsLoadResult(response: CourseSearch.CourseSearchSuggestionsLoad.Response)
    func presentSearchQueryUpdateResult(response: CourseSearch.SearchQueryUpdate.Response)
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

    // MARK: Private API

    private func makeSuggestionViewModel(_ searchQueryResult: SearchQueryResult) -> CourseSearchSuggestionViewModel {
        .init(uniqueIdentifier: searchQueryResult.id, title: searchQueryResult.query)
    }
}
