import CoreSpotlight
import Foundation

protocol SpotlightIndexingServiceProtocol: AnyObject {
    func indexSearchableItems(_ items: [SpotlightSearchableItem])
    func deleteAllSearchableItems()
}

extension SpotlightIndexingServiceProtocol {
    func indexCourses(_ courses: [Course]) {
        let courseSearchableItems = courses.map { CourseSpotlightSearchableItem(course: $0) }
        self.indexSearchableItems(courseSearchableItems)
    }
}

final class SpotlightIndexingService: SpotlightIndexingServiceProtocol {
    static let shared = SpotlightIndexingService()

    private let queue = DispatchQueue(label: "com.AlexKarpov.Stepic.SpotlightIndexingQueue")

    private init() {}

    func indexSearchableItems(_ items: [SpotlightSearchableItem]) {
        self.queue.async {
            let searchableItems = items.map { $0.searchableItem }
            let identifiers = items.map { "\($0.domainIdentifier).\($0.uniqueIdentifier)" }

            CSSearchableIndex.default().indexSearchableItems(
                searchableItems,
                completionHandler: { errorOrNil in
                    if let error = errorOrNil {
                        print("SpotlightIndexingService: error indexing items = \(identifiers), error = \(error)")
                    } else {
                        print("SpotlightIndexingService: indexed items = \(identifiers)")
                    }
                }
            )
        }
    }

    func deleteAllSearchableItems() {
        CSSearchableIndex.default().deleteAllSearchableItems()
    }
}
