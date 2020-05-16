import CoreSpotlight
import Foundation

protocol SpotlightContinueUserActivityServiceProtocol: AnyObject {
    func continueUserActivity(_ userActivity: NSUserActivity) -> Bool
}

final class SpotlightContinueUserActivityService: SpotlightContinueUserActivityServiceProtocol {
    private static let deepLinkRoutingDelay: TimeInterval = 0.3

    private let deepLinkRoutingService: DeepLinkRoutingService
    private let analytics: Analytics

    init(
        deepLinkRoutingService: DeepLinkRoutingService = DeepLinkRoutingService(),
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.deepLinkRoutingService = deepLinkRoutingService
        self.analytics = analytics
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

        self.analytics.send(.continueUserActivitySpotlightItemTapped(deepLinkRoute: deepLinkRoute))

        return true
    }
}
