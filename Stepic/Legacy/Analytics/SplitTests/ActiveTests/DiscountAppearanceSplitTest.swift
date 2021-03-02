import Foundation

final class DiscountAppearanceSplitTest: SplitTestProtocol {
    typealias GroupType = Group

    static let identifier = "discount_appearance"
    static let minParticipatingStartVersion = "1.0"

    var currentGroup: Group
    var analytics: ABAnalyticsServiceProtocol

    init(currentGroup: Group, analytics: ABAnalyticsServiceProtocol) {
        self.currentGroup = currentGroup
        self.analytics = analytics
    }

    enum Group: String, SplitTestGroupProtocol, CaseIterable {
        case discountTransparent = "DiscountTransparent"
        case discountGreen = "DiscountGreen"
        case discountPurple = "DiscountPurple"

        static var groups: [Group] = Self.allCases
    }
}
