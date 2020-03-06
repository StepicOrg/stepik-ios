import CoreSpotlight
import Foundation

protocol SpotlightIndexingServiceProtocol: AnyObject {
    func indexCourse(_ course: Course)
    func indexSearchableItem(_ spotlightSearchableItem: SpotlightSearchableItem)
    func deleteAllSearchableItems()
}

extension SpotlightIndexingServiceProtocol {
    func indexCourse(_ course: Course) {
        self.indexSearchableItem(CourseSpotlightSearchableItem(course: course))
    }
}

final class SpotlightIndexingService: SpotlightIndexingServiceProtocol {
    static let shared = SpotlightIndexingService()

    private let queue = DispatchQueue(label: "com.AlexKarpov.Stepic.SpotlightIndexingQueue")

    private init() {}

    func indexSearchableItem(_ spotlightSearchableItem: SpotlightSearchableItem) {
        let searchableItem = spotlightSearchableItem.searchableItem
        let identifier = "\(searchableItem.domainIdentifier ?? "").\(searchableItem.uniqueIdentifier)"

        self.queue.async {
            CSSearchableIndex.default().indexSearchableItems(
                [searchableItem],
                completionHandler: { errorOrNil in
                    if let error = errorOrNil {
                        print("SpotlightIndexingService: error indexing item = \(identifier), error = \(error)")
                    } else {
                        print("SpotlightIndexingService: indexed item = \(identifier)")
                    }
                }
            )
        }
    }

    func deleteAllSearchableItems() {
        CSSearchableIndex.default().deleteAllSearchableItems()
    }
}
