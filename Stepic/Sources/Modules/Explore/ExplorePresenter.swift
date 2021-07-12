import UIKit

protocol ExplorePresenterProtocol: BaseExplorePresenterProtocol {
    func presentContent(response: Explore.ContentLoad.Response)
    func presentLanguageSwitchBlock(response: Explore.LanguageSwitchAvailabilityCheck.Response)
    func presentCourseListState(response: Explore.CourseListStateUpdate.Response)
    func presentExploreCourseListFilter(response: Explore.ExploreCourseListFilterPresentation.Response)
    func presentSearchResultsCourseListFilter(response: Explore.SearchResultsCourseListFilterPresentation.Response)
    func presentSearchResultsCourseListFiltersUpdateResult(
        response: Explore.SearchResultsCourseListFiltersUpdate.Response
    )
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

    func presentSearchResultsCourseListFilter(response: Explore.SearchResultsCourseListFilterPresentation.Response) {
        let presentationDescription = CourseListFilter.PresentationDescription(
            availableFilters: .all,
            prefilledFilters: response.currentFilters,
            defaultCourseLanguage: response.defaultCourseLanguage
        )
        self.exploreViewController?.displaySearchResultsCourseListFilter(
            viewModel: .init(presentationDescription: presentationDescription)
        )
    }

    func presentExploreCourseListFilter(response: Explore.ExploreCourseListFilterPresentation.Response) {
        let presentationDescription = CourseListFilter.PresentationDescription(
            availableFilters: .all,
            prefilledFilters: response.currentFilters,
            defaultCourseLanguage: response.defaultCourseLanguage
        )
        self.exploreViewController?.displayExploreCourseListFilter(
            viewModel: .init(presentationDescription: presentationDescription)
        )
    }

    func presentSearchResultsCourseListFiltersUpdateResult(
        response: Explore.SearchResultsCourseListFiltersUpdate.Response
    ) {
        self.exploreViewController?.displaySearchResultsCourseListFiltersUpdateResult(
            viewModel: .init(filters: response.filters)
        )
    }
}
