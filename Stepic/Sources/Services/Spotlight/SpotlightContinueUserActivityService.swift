import CoreSpotlight
import Foundation

protocol SpotlightContinueUserActivityServiceProtocol: AnyObject {
    func continueUserActivity(_ userActivity: NSUserActivity) -> Bool
}

final class SpotlightContinueUserActivityService: SpotlightContinueUserActivityServiceProtocol {
    private static let deepLinkRoutingDelay: TimeInterval = 0.3

    private let deepLinkRoutingService: DeepLinkRoutingService

    init(deepLinkRoutingService: DeepLinkRoutingService = DeepLinkRoutingService()) {
        self.deepLinkRoutingService = deepLinkRoutingService
    }

    func continueUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == CSSearchableItemActionType,
              let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
              let deepLinkRoute = DeepLinkRoute(path: uniqueIdentifier) else {
            return false
        }

        // Small delay for pretty animation
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Self.deepLinkRoutingDelay,
            execute: {
                self.deepLinkRoutingService.route(deepLinkRoute)
            }
        )

        return true
    }
}
