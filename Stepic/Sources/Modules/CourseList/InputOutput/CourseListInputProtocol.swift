import Foundation

protocol CourseListInputProtocol: AnyObject {
    var moduleIdentifier: UniqueIdentifierType? { get set }
    /// Course list will be use data from network
    func setOnlineStatus()
    func loadAllCourses()
    func applyFilters(_ filters: [CourseListFilter.Filter])
}
