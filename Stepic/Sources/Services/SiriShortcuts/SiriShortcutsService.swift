import CoreSpotlight
import Foundation
import MobileCoreServices

@available(iOS 12.0, *)
protocol SiriShortcutsServiceProtocol: AnyObject {
    func getContinueLearningShortcut() -> NSUserActivity
}

@available(iOS 12.0, *)
final class SiriShortcutsService: SiriShortcutsServiceProtocol {
    func getContinueLearningShortcut() -> NSUserActivity {
        let activityType = NSUserActivity.continueLearningActivityType
        let userActivity = NSUserActivity(activityType: activityType)
        userActivity.persistentIdentifier = NSUserActivityPersistentIdentifier(activityType)
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPrediction = true
        userActivity.title = NSLocalizedString("SiriShortcutContinueLearningTitle", comment: "")

        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        attributes.keywords = [
             NSLocalizedString("SiriShortcutContinueLearningKeyword1", comment: ""),
             NSLocalizedString("SiriShortcutContinueLearningKeyword2", comment: ""),
             NSLocalizedString("SiriShortcutContinueLearningKeyword3", comment: "")
        ]
        attributes.displayName = NSLocalizedString("SiriShortcutContinueLearningTitle", comment: "")
        attributes.contentDescription = NSLocalizedString("SiriShortcutContinueLearningContentDescription", comment: "")
        userActivity.contentAttributeSet = attributes

        userActivity.suggestedInvocationPhrase = NSString.deferredLocalizedIntentsString(
            with: "SiriShortcutContinueLearningTitle"
        ) as String

        return userActivity
    }
}

// MARK: - NSUserActivity (IntentData) -

extension NSUserActivity {
    static let continueLearningActivityType = "com.AlexKarpov.Stepic.ContinueLearningUserActivity"
}
