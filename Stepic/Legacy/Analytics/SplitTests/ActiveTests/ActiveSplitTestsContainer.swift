import Foundation

final class ActiveSplitTestsContainer {
    static var activeSplitTests: [SplitTestPlainObject] {
        [
            SplitTestPlainObject(DiscountAppearanceSplitTest.self)
        ]
    }

    private static let splitTestingService: SplitTestingServiceProtocol = SplitTestingService(
        analyticsService: AnalyticsUserProperties(),
        storage: UserDefaults.standard
    )

    static func setActiveTestsGroups() {
        self.splitTestingService.fetchSplitTest(DiscountAppearanceSplitTest.self).setSplitTestGroup()
    }
}
