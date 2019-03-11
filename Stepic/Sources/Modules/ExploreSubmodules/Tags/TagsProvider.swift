import Foundation
import PromiseKit

protocol TagsProviderProtocol {
    func fetchTags() -> Guarantee<[CourseTag]>
}

final class TagsProvider: TagsProviderProtocol {
    func fetchTags() -> Guarantee<[CourseTag]> {
        return Guarantee { seal in
            seal(CourseTag.featuredTags)
        }
    }
}
