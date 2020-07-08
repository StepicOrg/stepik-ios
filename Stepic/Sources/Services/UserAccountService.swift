import Foundation

protocol UserAccountServiceProtocol: AnyObject {
    var currentUser: User? { get }
    var currentUserID: User.IdType? { get }
    var isAuthorized: Bool { get }

    func logOut()
}

/// Wrapper for ugly AuthInfo
final class UserAccountService: UserAccountServiceProtocol {
    var currentUser: User? { AuthInfo.shared.user }

    var currentUserID: User.IdType? { AuthInfo.shared.userId }

    var isAuthorized: Bool { AuthInfo.shared.isAuthorized }

    func logOut() { AuthInfo.shared.token = nil }
}
