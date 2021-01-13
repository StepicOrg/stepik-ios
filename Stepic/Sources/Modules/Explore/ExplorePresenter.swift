import UIKit

protocol ExplorePresenterProtocol: BaseExplorePresenterProtocol {
    func presentContent(response: Explore.ContentLoad.Response)
    func presentLanguageSwitchBlock(response: Explore.LanguageSwitchAvailabilityCheck.Response)
    func presentCourseListState(response: Explore.CourseListStateUpdate.Response)
    func presentCourseListFilter(response: Explore.CourseListFilterPresentation.Response)
    func presentSearchResultsCourseListFilters(response: Explore.SearchResultsCourseListFiltersUpdate.Response)
}

final class ExplorePresenter: BaseExplorePresenter, ExplorePresenterProtocol {
    lazy var exploreViewController = self.viewController as? ExploreViewControllerProtocol

    func presentContent(response: Explore.ContentLoad.Response) {
        self.exploreViewController?.displayContent(
            viewModel: .init(state: .normal(contentLanguage: response.contentLanguage))
        )
    }

    func presentLanguageSwitchBlock(response: Explore.LanguageSwitchAvailabilityCheck.Response) {
        self.exploreViewController?.displayLanguageSwitchBlock(
            viewModel: .init(isHidden: response.isHidden)
        )
    }

    func presentCourseListState(response: Explore.CourseListStateUpdate.Response) {
        self.exploreViewController?.displayModuleErrorState(
            viewModel: .init(
                module: response.module,
                result: response.result
            )
        )
    }

    func presentCourseListFilter(response: Explore.CourseListFilterPresentation.Response) {
        let presentationDescription = CourseListFilter.PresentationDescription(
            availableFilters: .all,
            prefilledFilters: response.currentFilters,
            defaultCourseLanguage: response.defaultCourseLanguage
        )
        self.exploreViewController?.displayCourseListFilter(
            viewModel: .init(presentationDescription: presentationDescription)
        )
    }

    func presentSearchResultsCourseListFilters(response: Explore.SearchResultsCourseListFiltersUpdate.Response) {
        self.exploreViewController?.displaySearchResultsCourseListFilters(viewModel: .init(filters: response.filters))
    }
}
