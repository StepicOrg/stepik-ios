import Alamofire
import Foundation

extension HTTPHeader {
    /// Returns Stepik's default `Content-Type` header, appropriate for the authorization requests.
    ///
    /// Field: `Content-Type`.
    ///
    /// Value: `application/x-www-form-urlencoded`.
    static let stepikAuthContentType: HTTPHeader = .contentType("application/x-www-form-urlencoded")

    /// Returns Stepik's default `User-Agent` header.
    ///
    /// Field: `User-Agent`.
    ///
    /// - Returns: The header.
    static var stepikUserAgent: HTTPHeader = {
        guard let bundleID = Bundle.main.bundleIdentifier,
              let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String else {
            return .userAgent("Stepik (iOS app)")
        }

        let osVersion = [
            "\(DeviceInfo.current.OSVersion.major)",
            "\(DeviceInfo.current.OSVersion.minor)",
            "\(DeviceInfo.current.OSVersion.patch)"
        ].joined(separator: ".")

        let userAgent = "Stepik/\(version) (\(bundleID); build \(build); iOS \(osVersion))"

        return .userAgent(userAgent)
    }()
}
