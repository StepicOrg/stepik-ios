import Foundation

protocol ContinueCourseOutputProtocol: class {
    func hideContinueCourse()
    func presentLastStep(course: Course, isAdaptive: Bool)
}
