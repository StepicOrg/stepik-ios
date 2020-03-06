import CoreSpotlight
import Foundation

protocol SpotlightIndexingServiceProtocol: AnyObject {
    func index(_ spotlightSearchableItem: SpotlightSearchableItem)
}

final class SpotlightIndexingService: SpotlightIndexingServiceProtocol {
    static let shared = SpotlightIndexingService()

    private let queue = DispatchQueue(label: "com.AlexKarpov.Stepic.SpotlightIndexingQueue")

    private init() {}

    func index(_ spotlightSearchableItem: SpotlightSearchableItem) {
        let searchableItem = spotlightSearchableItem.searchableItem

        self.queue.async {
            CSSearchableIndex.default().indexSearchableItems(
                [searchableItem],
                completionHandler: { errorOrNil in
                    if let error = errorOrNil {
                        print(
                            "SpotlightIndexingService: error indexing item = \(searchableItem), error = \(error)"
                        )
                    } else {
                        print("SpotlightIndexingService: indexed item = \(searchableItem)")
                    }
                }
            )
        }
    }
}
