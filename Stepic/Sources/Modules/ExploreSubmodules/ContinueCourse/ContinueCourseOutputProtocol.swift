import Foundation

protocol ContinueCourseOutputProtocol: AnyObject {
    func presentLastStep(course: Course, isAdaptive: Bool, viewSource: AnalyticsEvent.CourseViewSource)
}
