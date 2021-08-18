import Foundation

final class ActiveSplitTestsContainer {
    private static let splitTestingService: SplitTestingServiceProtocol = SplitTestingService(
        analyticsService: AnalyticsUserProperties(),
        storage: UserDefaults.standard
    )

    static func setActiveTestsGroups() {
        self.splitTestingService.fetchSplitTest(DiscountAppearanceSplitTest.self).setSplitTestGroup()
    }
}
