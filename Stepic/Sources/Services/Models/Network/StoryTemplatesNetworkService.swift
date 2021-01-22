import Foundation
import PromiseKit

protocol StoryTemplatesNetworkServiceProtocol: AnyObject {
    func fetch(ids: [Story.IdType]) -> Promise<[Story]>
    func fetch(language: ContentLanguage, maxVersion: Int, isPublished: Bool?) -> Promise<[Story]>
}

extension StoryTemplatesNetworkServiceProtocol {
    func fetch(id: Story.IdType) -> Promise<Story?> {
        self.fetch(ids: [id]).then { stories -> Promise<Story?> in
            .value(stories.first)
        }
    }
}

final class StoryTemplatesNetworkService: StoryTemplatesNetworkServiceProtocol {
    private let storyTemplatesAPI: StoryTemplatesAPI

    init(storyTemplatesAPI: StoryTemplatesAPI) {
        self.storyTemplatesAPI = storyTemplatesAPI
    }

    func fetch(ids: [Story.IdType]) -> Promise<[Story]> {
        self.storyTemplatesAPI.retrieve(ids: ids).then { stories -> Promise<[Story]> in
            let reorderedStories = stories.reordered(order: ids, transform: { $0.id })
            return .value(reorderedStories)
        }
    }

    func fetch(language: ContentLanguage, maxVersion: Int, isPublished: Bool?) -> Promise<[Story]> {
        self.storyTemplatesAPI.retrieve(isPublished: isPublished, language: language, maxVersion: maxVersion)
    }
}
