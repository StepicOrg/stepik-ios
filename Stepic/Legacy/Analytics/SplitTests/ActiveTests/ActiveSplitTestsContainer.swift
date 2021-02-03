import Foundation

final class ActiveSplitTestsContainer {
    private static let splitTestingService = SplitTestingService(
        analyticsService: AnalyticsUserProperties(),
        storage: UserDefaults.standard
    )

    static func setActiveTestsGroups() {
        self.splitTestingService.fetchSplitTest(DiscountAppearanceSplitTest.self).setSplitTestGroup()
    }
}
