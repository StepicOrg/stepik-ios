import Foundation
import PromiseKit

protocol ExploreInteractorProtocol: BaseExploreInteractorProtocol {
    func doContentLoad(request: Explore.ContentLoad.Request)
    func doLanguageSwitchBlockLoad(request: Explore.LanguageSwitchAvailabilityCheck.Request)
}

final class ExploreInteractor: BaseExploreInteractor, ExploreInteractorProtocol {
    private lazy var explorePresenter = self.presenter as? ExplorePresenterProtocol
    let contentLanguageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityServiceProtocol

    init(
        presenter: ExplorePresenterProtocol,
        contentLanguageService: ContentLanguageServiceProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol,
        languageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityServiceProtocol
    ) {
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
}

extension ExploreInteractor: StoriesOutputProtocol {
    func hideStories() {
        self.explorePresenter?.presentStoriesBlock(response: .init(isHidden: true))
    }
}

extension ExploreInteractor: TagsOutputProtocol {
    func presentCourseList(type: TagCourseListType) {
        self.doFullscreenCourseListPresentation(
            request: .init(
                presentationDescription: nil,
                courseListType: type
            )
        )
    }
}

extension ExploreInteractor: CourseListCollectionOutputProtocol {
    func presentCourseList(
        presentationDescription: CourseList.PresentationDescription,
        type: CollectionCourseListType
    ) {
        self.doFullscreenCourseListPresentation(
            request: .init(
                presentationDescription: presentationDescription,
                courseListType: type
            )
        )
    }
}
