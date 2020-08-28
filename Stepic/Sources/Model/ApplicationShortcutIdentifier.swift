import Foundation

enum ApplicationShortcutIdentifier: String {
    case continueLearning = "ContinueLearning"
    case searchCourses = "SearchCourses"

    init?(fullIdentifier: String) {
        guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
            return nil
        }
        self.init(rawValue: shortIdentifier)
    }
}
