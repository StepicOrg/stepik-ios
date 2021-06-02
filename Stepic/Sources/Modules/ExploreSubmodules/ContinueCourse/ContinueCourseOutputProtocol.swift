import Foundation

protocol ContinueCourseOutputProtocol: AnyObject {
    func hideContinueCourse()
    func presentLastStep(
        course: Course,
        isAdaptive: Bool,
        source: AnalyticsEvent.CourseContinueSource,
        viewSource: AnalyticsEvent.CourseViewSource
    )
}
