import Foundation

protocol CourseInfoSubmoduleProtocol: class {
    func update(with course: Course, isOnline: Bool)
    func handleControllerAppearance()
}
