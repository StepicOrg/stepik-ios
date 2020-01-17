import Foundation

final class AboutCourseStringSplitTest: SplitTestProtocol {
    typealias GroupType = Group

    static let identifier = "about_course_string"
    static let minParticipatingStartVersion = "1.109"

    var currentGroup: Group
    var analytics: ABAnalyticsServiceProtocol

    init(currentGroup: Group, analytics: ABAnalyticsServiceProtocol) {
        self.currentGroup = currentGroup
        self.analytics = analytics
    }

    enum Group: String, SplitTestGroupProtocol {
        case control
        case test

        static var groups: [Group] = [.control, .test]
    }
}
