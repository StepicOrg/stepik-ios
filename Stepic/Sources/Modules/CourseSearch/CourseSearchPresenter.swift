import UIKit

protocol CourseSearchPresenterProtocol {
    func presentCourseContent(response: CourseSearch.CourseContentLoad.Response)
}

final class CourseSearchPresenter: CourseSearchPresenterProtocol {
    weak var viewController: CourseSearchViewControllerProtocol?

    func presentCourseContent(response: CourseSearch.CourseContentLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeViewModel(
                course: data.course,
                searchQueryResults: data.searchQueryResults
            )
            self.viewController?.displayCourseContent(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayCourseContent(viewModel: .init(state: .error(.content)))
        }
    }

    // MARK: Private API

    private func makeViewModel(
        course: Course,
        searchQueryResults: [SearchQueryResult]
    ) -> CourseSearchViewModel {
        let searchBarPlaceholder = String(
            format: NSLocalizedString("CourseSearchBarPlaceholder", comment: ""),
            arguments: [course.title]
        )

        let suggestions = searchQueryResults.map(self.makeSuggestionViewModel(_:))

        return CourseSearchViewModel(
            placeholderText: searchBarPlaceholder,
            suggestions: suggestions
        )
    }

    private func makeSuggestionViewModel(_ searchQueryResult: SearchQueryResult) -> CourseSearchViewModel.Suggestion {
        .init(uniqueIdentifier: searchQueryResult.id, title: searchQueryResult.query)
    }
}
