import Foundation

protocol UserAccountServiceProtocol: AnyObject {
    var currentUser: User? { get }
    var isAuthorized: Bool { get }

    func logOut()
}

/// Wrapper for ugly AuthInfo
final class UserAccountService: UserAccountServiceProtocol {
    var currentUser: User? { AuthInfo.shared.user }

    var isAuthorized: Bool { AuthInfo.shared.isAuthorized }

    func logOut() { AuthInfo.shared.token = nil }
}
