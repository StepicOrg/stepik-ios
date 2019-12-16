import Foundation

protocol UserAccountServiceProtocol: AnyObject {
    var currentUser: User? { get }
    var isAuthorized: Bool { get }
}

/// Wrapper for ugly AuthInfo
final class UserAccountService: UserAccountServiceProtocol {
    var currentUser: User? { AuthInfo.shared.user }

    var isAuthorized: Bool { AuthInfo.shared.isAuthorized }
}
