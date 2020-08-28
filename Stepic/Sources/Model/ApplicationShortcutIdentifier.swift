import Foundation

enum ApplicationShortcutIdentifier: String {
    case continueLearning = "ContinueLearning"
    case searchCourses = "SearchCourses"
    case profile = "Profile"
    case notifications = "Notifications"

    init?(fullIdentifier: String) {
        guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
            return nil
        }
        self.init(rawValue: shortIdentifier)
    }
}
