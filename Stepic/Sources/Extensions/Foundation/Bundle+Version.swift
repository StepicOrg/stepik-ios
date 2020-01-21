import Foundation

extension Bundle {
    var versionNumber: String? {
        self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumber: String? {
        self.infoDictionary?["CFBundleVersion"] as? String
    }
}
