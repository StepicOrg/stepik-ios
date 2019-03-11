import Foundation

protocol UserAccountServiceProtocol: class {
    var currentUser: User? { get }
    var isAuthorized: Bool { get }
}

/// Wrapper for ugly AuthInfo
final class UserAccountService: UserAccountServiceProtocol {
    var currentUser: User? {
        return AuthInfo.shared.user
    }

    var isAuthorized: Bool {
        return AuthInfo.shared.isAuthorized
    }
}
