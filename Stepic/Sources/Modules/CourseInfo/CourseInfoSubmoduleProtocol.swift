import Foundation

protocol CourseInfoSubmoduleProtocol: AnyObject {
    func update(with course: Course, viewSource: AnalyticsEvent.CourseViewSource, isOnline: Bool)
    func handleControllerAppearance()
}
