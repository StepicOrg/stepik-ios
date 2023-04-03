import Foundation

// swiftlint:disable force_cast

final class WidgetService {
    private var _widgetContentIndexingService: AnyObject?
    @available(iOS 14.0, *)
    private var widgetContentIndexingService: WidgetContentIndexingServiceProtocol {
        if _widgetContentIndexingService == nil {
            _widgetContentIndexingService = WidgetContentIndexingService.default
        }
        return _widgetContentIndexingService as! WidgetContentIndexingServiceProtocol
    }

    private var _widgetRoutingService: AnyObject?
    @available(iOS 14.0, *)
    private var widgetRoutingService: WidgetRoutingServiceProtocol {
        if _widgetRoutingService == nil {
            _widgetRoutingService = WidgetRoutingService.default
        }
        return _widgetRoutingService as! WidgetRoutingServiceProtocol
    }

    private var _widgetUserDefaults: AnyObject?
    @available(iOS 14.0, *)
    private var widgetUserDefaults: WidgetUserDefaultsProtocol {
        if _widgetUserDefaults == nil {
            _widgetUserDefaults = WidgetUserDefaults.default
        }
        return _widgetUserDefaults as! WidgetUserDefaultsProtocol
    }

    private var _widgetTokenFileManager: AnyObject?
    @available(iOS 14.0, *)
    private var widgetTokenFileManager: StepikWidgetTokenFileManagerProtocol {
        if _widgetTokenFileManager == nil {
            _widgetTokenFileManager = StepikWidgetTokenFileManager.default
        }
        return _widgetTokenFileManager as! StepikWidgetTokenFileManagerProtocol
    }

    @available(iOS 14.0, *)
    func startIndexingContent(force: Bool = false) {
        self.widgetContentIndexingService.startIndexing(force: force)
    }

    @available(iOS 14.0, *)
    func stopIndexingContent() {
        self.widgetContentIndexingService.stopIndexing()
    }

    @available(iOS 14.0, *)
    func getLastWidgetSize() -> Int {
        self.widgetUserDefaults.lastWidgetSize
    }

    @available(iOS 14.0, *)
    func getIsWidgetAdded() -> Bool {
        self.widgetUserDefaults.isWidgetAdded
    }

    @available(iOS 14.0, *)
    func canOpenRouteURL(_ url: URL) -> Bool {
        self.widgetRoutingService.canOpen(url: url)
    }

    @available(iOS 14.0, *)
    func openRouteURL(_ url: URL) {
        self.widgetRoutingService.open(url: url)
    }

    @available(iOS 14.0, *)
    func writeToken(_ token: StepikWidgetToken) throws {
        try self.widgetTokenFileManager.write(token: token)
    }
}
