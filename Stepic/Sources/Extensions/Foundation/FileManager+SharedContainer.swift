import Foundation

extension FileManager {
    static var widgetContainerURL: URL {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.AlexKarpov.Stepic.WidgetContent"
        ).require()
    }
}
