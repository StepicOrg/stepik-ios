import Foundation

protocol CourseListInputProtocol: class {
    var moduleIdentifier: UniqueIdentifierType? { get set }

    /// Course list will be use data from network
    func setOnlineStatus()
}
