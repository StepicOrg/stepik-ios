import Alamofire
import Foundation
import SwiftyJSON

@available(*, deprecated, message: "Legacy class")
final class ApiDataDownloader {
    static let attempts = AttemptsAPI()
    static let auth = AuthAPI()
    static let courses = CoursesAPI()
    static let discussionThreads = DiscussionThreadsAPI()
    static let enrollments = EnrollmentsAPI()
    static let lastSteps = LastStepsAPI()
    static let lessons = LessonsAPI()
    static let notifications = NotificationsAPI()
    static let notificationsStatusAPI = NotificationStatusesAPI()
    static let progresses = ProgressesAPI()
    static let queries = QueriesAPI()
    static let sections = SectionsAPI()
    static let stepics = StepicsAPI()
    static let steps = StepsAPI()
    static let submissions = SubmissionsAPI()
    static let units = UnitsAPI()
    static let userActivities = UserActivitiesAPI()
    static let users = UsersAPI()
    static let views = ViewsAPI()
    static let devices = DevicesAPI()
}

enum RefreshMode {
    case delete
    case update
}
