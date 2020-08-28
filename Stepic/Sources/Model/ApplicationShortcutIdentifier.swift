import Foundation

enum ApplicationShortcutIdentifier: String {
    case continueLearning = "ContinueLearning"

    init?(fullIdentifier: String) {
        guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
            return nil
        }
        self.init(rawValue: shortIdentifier)
    }
}
