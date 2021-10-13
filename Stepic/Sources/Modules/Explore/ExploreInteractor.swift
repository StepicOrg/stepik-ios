import Foundation
import PromiseKit

protocol ExploreInteractorProtocol: BaseExploreInteractorProtocol {
    func doContentLoad(request: Explore.ContentLoad.Request)
    func doLanguageSwitchBlockLoad(request: Explore.LanguageSwitchAvailabilityCheck.Request)
    func doSearchResultsCourseListFiltersUpdate(request: Explore.SearchResultsCourseListFiltersUpdate.Request)
    func doSearchResultsCourseListFilterPresentation(request: Explore.SearchResultsCourseListFilterPresentation.Request)
    func doExploreCourseListFilterPresentation(request: Explore.ExploreCourseListFilterPresentation.Request)
}

final class ExploreInteractor: BaseExploreInteractor, ExploreInteractorProtocol {
    private lazy var explorePresenter = self.presenter as? ExplorePresenterProtocol

    private let userAccountService: UserAccountServiceProtocol
    private let personalOffersService: PersonalOffersServiceProtocol
    private let contentLanguageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityServiceProtocol

    private lazy var currentSearchResultsCourseListFilters = self.getDefaultSearchResultsCourseListFilters()

    init(
        presenter: ExplorePresenterProtocol,
        contentLanguageService: ContentLanguageServiceProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol,
        userAccountService: UserAccountServiceProtocol,
        personalOffersService: PersonalOffersServiceProtocol,
        languageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityServiceProtocol
    ) {
        self.userAccountService = userAccountService
        self.personalOffersService = personalOffersService
        self.contentLanguageSwitchAvailabilityService = languageSwitchAvailabilityService

        super.init(
            presenter: presenter,
            contentLanguageService: contentLanguageService,
            networkReachabilityService: networkReachabilityService
        )
    }

    func doContentLoad(request: Explore.ContentLoad.Request) {
        self.explorePresenter?.presentContent(
            response: .init(contentLanguage: self.contentLanguageService.globalContentLanguage)
        )
        self.syncPersonalOffers()
    }

    func doLanguageSwitchBlockLoad(request: Explore.LanguageSwitchAvailabilityCheck.Request) {
        self.explorePresenter?.presentLanguageSwitchBlock(
            response: .init(
                isHidden: !self.contentLanguageSwitchAvailabilityService
                    .shouldShowLanguageSwitchOnExplore
            )
        )
        self.contentLanguageSwitchAvailabilityService.shouldShowLanguageSwitchOnExplore = false
    }

    func doSearchResultsCourseListFiltersUpdate(request: Explore.SearchResultsCourseListFiltersUpdate.Request) {
        self.currentSearchResultsCourseListFilters = request.filters.isEmpty
            ? self.getDefaultSearchResultsCourseListFilters()
            : request.filters
        self.explorePresenter?.presentSearchResultsCourseListFiltersUpdateResult(
            response: .init(filters: self.currentSearchResultsCourseListFilters)
        )
    }

    func doSearchResultsCourseListFilterPresentation(
        request: Explore.SearchResultsCourseListFilterPresentation.Request
    ) {
        self.explorePresenter?.presentSearchResultsCourseListFilter(
            response: .init(
                currentFilters: self.currentSearchResultsCourseListFilters,
                defaultCourseLanguage: self.getDefaultSearchResultsCourseListFilterLanguage()
            )
        )
    }

    func doExploreCourseListFilterPresentation(request: Explore.ExploreCourseListFilterPresentation.Request) {
        self.explorePresenter?.presentExploreCourseListFilter(
            response: .init(
                currentFilters: self.getDefaultSearchResultsCourseListFilters(),
                defaultCourseLanguage: self.getDefaultSearchResultsCourseListFilterLanguage()
            )
        )
    }

    // MARK: Override BaseExploreInteractor

    override func presentEmptyState(sourceModule: CourseListInputProtocol) {
        guard let exploreSubmodule = self.determineModule(sourceModule: sourceModule) else {
            return
        }

        self.explorePresenter?.presentCourseListState(
            response: .init(
                module: exploreSubmodule,
                result: .empty
            )
        )
    }

    override func presentError(sourceModule: CourseListInputProtocol) {
        guard let exploreSubmodule = self.determineModule(sourceModule: sourceModule) else {
            return
        }

        self.explorePresenter?.presentCourseListState(
            response: .init(
                module: exploreSubmodule,
                result: .error
            )
        )
    }

    private func determineModule(sourceModule: CourseListInputProtocol) -> Explore.Submodule? {
        if sourceModule.moduleIdentifier == Explore.Submodule.visitedCourses.uniqueIdentifier {
            return .visitedCourses
        }
        return nil
    }

    private func syncPersonalOffers() {
        guard self.networkReachabilityService.isReachable else {
            return
        }

        guard let currentUser = self.userAccountService.currentUser,
              !currentUser.isGuest && self.userAccountService.isAuthorized else {
            return
        }

        self.personalOffersService.syncPersonalOffers(userID: currentUser.id).cauterize()
    }
}

extension ExploreInteractor: StoriesOutputProtocol {
    func hideStories() {
        self.explorePresenter?.presentStoriesBlock(response: .init(isHidden: true))
    }

    func handleStoriesStatusBarStyleUpdate(_ statusBarStyle: UIStatusBarStyle) {
        self.explorePresenter?.presentStatusBarStyle(response: .init(statusBarStyle: statusBarStyle))
    }
}

extension ExploreInteractor: CourseListFilterOutputProtocol {
    func handleCourseListFilterDidFinishWithFilters(_ filters: [CourseListFilter.Filter]) {
        self.doSearchResultsCourseListFiltersUpdate(request: .init(filters: filters))
    }

    // MARK: Private Helpers

    private func getDefaultSearchResultsCourseListFilters() -> [CourseListFilter.Filter] {
        [.courseLanguage(self.getDefaultSearchResultsCourseListFilterLanguage())]
    }

    private func getDefaultSearchResultsCourseListFilterLanguage() -> CourseListFilter.Filter.CourseLanguage {
        self.contentLanguageService.globalContentLanguage == .russian ? .any : .english
    }
}

extension ExploreInteractor: CatalogBlocksOutputProtocol {
    func presentCourseList(type: CourseListType, presentationDescription: CourseList.PresentationDescription?) {
        self.doFullscreenCourseListPresentation(
            request: .init(
                presentationDescription: presentationDescription,
                courseListType: type
            )
        )
    }

    func presentProfile(id: User.IdType) {
        self.explorePresenter?.presentProfile(response: .init(userID: id))
    }

    func hideCatalogBlocks() {
        self.explorePresenter?.presentCourseListState(
            response: .init(
                module: Explore.Submodule.catalogBlocks,
                result: .empty
            )
        )
    }
}
