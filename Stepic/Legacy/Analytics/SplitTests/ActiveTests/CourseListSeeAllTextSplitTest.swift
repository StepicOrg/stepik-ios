import Foundation

final class CourseListSeeAllTextSplitTest: SplitTestProtocol {
    typealias GroupType = Group

    static let identifier = "course_list_see_all_text"
    static let minParticipatingStartVersion = "1.113"

    var currentGroup: Group
    var analytics: ABAnalyticsServiceProtocol

    init(currentGroup: Group, analytics: ABAnalyticsServiceProtocol) {
        self.currentGroup = currentGroup
        self.analytics = analytics
    }

    enum Group: String, SplitTestGroupProtocol, CaseIterable {
        case control = "control"
        case testDetailIndicator = "test_detail_indicator"
        case testText = "test_text"
        case testTextDetailIndicator = "test_text_detail_indicator"

        static var groups: [Group] = Self.allCases

        var seeAllTitle: String {
            switch self {
            case .control:
                return NSLocalizedString("ShowAll", comment: "")
            case .testDetailIndicator:
                return NSLocalizedString("ShowAllTestDetailIndicator", comment: "")
            case .testText:
                return NSLocalizedString("ShowAllTestText", comment: "")
            case .testTextDetailIndicator:
                return NSLocalizedString("ShowAllTestTextDetailIndicator", comment: "")
            }
        }
    }
}
