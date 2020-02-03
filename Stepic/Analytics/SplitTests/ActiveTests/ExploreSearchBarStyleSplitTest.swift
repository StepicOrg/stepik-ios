import Foundation

final class ExploreSearchBarStyleSplitTest: SplitTestProtocol {
    typealias GroupType = Group

    static let identifier = "explore_search_bar_style"
    static let minParticipatingStartVersion = "1.111"

    var currentGroup: Group
    var analytics: ABAnalyticsServiceProtocol

    init(currentGroup: Group, analytics: ABAnalyticsServiceProtocol) {
        self.currentGroup = currentGroup
        self.analytics = analytics
    }

    enum Group: String, SplitTestGroupProtocol {
        case control = "control"
        case test = "test"

        static var groups: [Group] = [.control, .test]

        var searchBarStyle: SearchBarStyle {
            switch self {
            case .control:
                return .legacy
            case .test:
                return .new
            }
        }
    }

    enum SearchBarStyle {
        case new
        case legacy
    }
}
