import Foundation

protocol CourseInfoSubmoduleProtocol: AnyObject {
    func update(with course: Course, isOnline: Bool)
    func handleControllerAppearance()
}
