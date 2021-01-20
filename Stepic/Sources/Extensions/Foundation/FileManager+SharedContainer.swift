import Foundation

extension FileManager {
    static var widgetContainerURL: URL {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: WidgetConstants.appGroupName
        ).require()
    }
}
