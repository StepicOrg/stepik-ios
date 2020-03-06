import CoreSpotlight
import Foundation

protocol SpotlightContinueUserActivityServiceProtocol: AnyObject {
    func continueUserActivity(_ userActivity: NSUserActivity) -> Bool
}

final class SpotlightContinueUserActivityService: SpotlightContinueUserActivityServiceProtocol {
    func continueUserActivity(_ userActivity: NSUserActivity) -> Bool {
        fatalError("continueUserActivity(_:) has not been implemented")
    }
}
