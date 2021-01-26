import Foundation
import PromiseKit

enum StoriesViewState {
    case normal
    case empty
    case loading
}

protocol StoriesViewProtocol: AnyObject {
    func set(state: StoriesViewState)
    func set(stories: [Story])
    func updateStory(index: Int)
}

protocol StoriesPresenterProtocol: AnyObject {
    func refresh()
}

protocol StoriesOutputProtocol: AnyObject {
    func hideStories()
    func handleStoriesStatusBarStyleUpdate(_ statusBarStyle: UIStatusBarStyle)
}

final class StoriesPresenter: StoriesPresenterProtocol {
    weak var view: StoriesViewProtocol?
    weak var moduleOutput: StoriesOutputProtocol?

    var stories: [Story] = []

    private let storyTemplatesNetworkService: StoryTemplatesNetworkServiceProtocol
    private let contentLanguageService: ContentLanguageServiceProtocol
    private let userAccountService: UserAccountServiceProtocol
    private let personalOffersService: PersonalOffersServiceProtocol

    init(
        view: StoriesViewProtocol,
        storyTemplatesNetworkService: StoryTemplatesNetworkServiceProtocol,
        contentLanguageService: ContentLanguageServiceProtocol,
        userAccountService: UserAccountServiceProtocol,
        personalOffersService: PersonalOffersServiceProtocol
    ) {
        self.view = view
        self.storyTemplatesNetworkService = storyTemplatesNetworkService
        self.contentLanguageService = contentLanguageService
        self.userAccountService = userAccountService
        self.personalOffersService = personalOffersService

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(StoriesPresenter.storyDidAppear(_:)),
            name: .storyDidAppear,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func storyDidAppear(_ notification: Foundation.Notification) {
        guard let storyID = (notification as NSNotification).userInfo?["id"] as? Int,
              let index = self.stories.firstIndex(where: { $0.id == storyID }) else {
            return
        }

        self.stories[index].isViewed.value = true
        self.view?.updateStory(index: index)
    }

    func refresh() {
        self.view?.set(state: .loading)

        var isPublished: Bool?
        if self.userAccountService.currentUser?.profileEntity?.isStaff != true {
            isPublished = true
        }

        self.storyTemplatesNetworkService.fetch(
            language: self.contentLanguageService.globalContentLanguage,
            maxVersion: StepikApplicationsInfo.Versions.stories ?? 0,
            isPublished: isPublished
        ).then { templateStories -> Guarantee<([Story], [Story.IdType])> in
            self.fetchPromoStoriesIDs().map { (templateStories, $0) }
        }.then { templateStories, promoStoriesIDs -> Guarantee<[Story]> in
            let templateStoriesIDs = Set(templateStories.map(\.id))
            let promoStoriesIDsToFetch = Array(Set(promoStoriesIDs).subtracting(templateStoriesIDs))

            if promoStoriesIDsToFetch.isEmpty {
                return .value(templateStories)
            } else {
                return Guarantee(
                    self.storyTemplatesNetworkService.fetch(ids: promoStoriesIDsToFetch),
                    fallback: nil
                ).map { templateStories + ($0 ?? []) }
            }
        }.done { stories in
            self.stories = stories
                .filter { $0.isSupported }
                .sorted { $0.position >= $1.position }
                .sorted { !($0.isViewed.value) || ($1.isViewed.value) }

            self.view?.set(state: self.stories.isEmpty ? .empty : .normal)
            self.view?.set(stories: self.stories)

            if self.stories.isEmpty {
                self.moduleOutput?.hideStories()
            }
        }.catch { _ in
            self.view?.set(state: self.stories.isEmpty ? .empty : .normal)
        }
    }

    private func fetchPromoStoriesIDs() -> Guarantee<[Story.IdType]> {
        guard self.userAccountService.isAuthorized,
              let userID = self.userAccountService.currentUserID else {
            return .value([])
        }

        return Guarantee { seal in
            self.personalOffersService.fetchPersonalOffer(userID: userID).done { storageRecord in
                guard let data = storageRecord?.data as? PersonalOfferStorageRecordData else {
                    return seal([])
                }

                seal(data.promoStories)
            }.catch { _ in
                seal([])
            }
        }
    }
}

// MARK: - StoriesPresenter: OpenedStoriesOutputProtocol -

extension StoriesPresenter: OpenedStoriesOutputProtocol {
    func handleOpenedStoriesStatusBarStyleUpdate(_ statusBarStyle: UIStatusBarStyle) {
        self.moduleOutput?.handleStoriesStatusBarStyleUpdate(statusBarStyle)
    }
}
