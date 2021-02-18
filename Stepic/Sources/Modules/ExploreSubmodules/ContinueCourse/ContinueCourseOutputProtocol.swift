import Foundation

protocol ContinueCourseOutputProtocol: AnyObject {
    func hideContinueCourse()
    func presentLastStep(course: Course, isAdaptive: Bool, viewSource: AnalyticsEvent.CourseViewSource)
    func presentCatalog()
}
