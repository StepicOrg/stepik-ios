import Foundation

protocol NewProfileSubmoduleProtocol: AnyObject {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool)
}
