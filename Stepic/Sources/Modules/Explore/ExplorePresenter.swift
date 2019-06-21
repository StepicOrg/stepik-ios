import UIKit

protocol ExplorePresenterProtocol: BaseExplorePresenterProtocol {
    func presentContent(response: Explore.ContentLoad.Response)
    func presentLanguageSwitchBlock(response: Explore.LanguageSwitchAvailabilityCheck.Response)
    func presentStoriesBlock(response: Explore.StoriesVisibilityUpdate.Response)
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

    func presentStoriesBlock(response: Explore.StoriesVisibilityUpdate.Response) {
        self.exploreViewController?.displayStoriesBlock(
            viewModel: .init(isHidden: response.isHidden)
        )
    }
}
