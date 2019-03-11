import Foundation

protocol CourseListOutputProtocol: class {
    func presentCourseInfo(course: Course)
    func presentCourseSyllabus(course: Course)
    func presentLastStep(course: Course, isAdaptive: Bool)
    func presentAuthorization()

    func presentEmptyState(sourceModule: CourseListInputProtocol)
    func presentError(sourceModule: CourseListInputProtocol)
}
