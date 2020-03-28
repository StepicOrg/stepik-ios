import Alamofire
import Foundation

extension HTTPHeader {
    /// Returns Stepik's default `Content-Type` header, appropriate for the authorization requests.
    ///
    /// Field: `Content-Type`.
    ///
    /// Value: `application/x-www-form-urlencoded`.
    static let stepikAuthContentType: HTTPHeader = .contentType("application/x-www-form-urlencoded")
}
