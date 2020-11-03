import Foundation

protocol CourseListOutputProtocol: AnyObject {
    func presentCourseInfo(course: Course, viewSource: AnalyticsEvent.CourseViewSource)
    func presentCourseSyllabus(course: Course, viewSource: AnalyticsEvent.CourseViewSource)
    func presentLastStep(course: Course, isAdaptive: Bool, viewSource: AnalyticsEvent.CourseViewSource)
    func presentAuthorization()
    func presentPaidCourseInfo(course: Course)

    func presentEmptyState(sourceModule: CourseListInputProtocol)
    func presentError(sourceModule: CourseListInputProtocol)
    func presentLoadedState(sourceModule: CourseListInputProtocol)
}
