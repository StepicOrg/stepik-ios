import Foundation

@available(iOS 14.0, *)
protocol StepikWidgetTokenFileManagerProtocol: AnyObject {
    func read() -> StepikWidgetToken?
    func write(token: StepikWidgetToken) throws
}

@available(iOS 14.0, *)
final class StepikWidgetTokenFileManager: StepikWidgetTokenFileManagerProtocol {
    static let `default` = StepikWidgetTokenFileManager(containerURL: FileManager.widgetContainerURL)

    private static let fileName = "access-token"

    private let containerURL: URL

    private var archiveURL: URL {
        self.containerURL.appendingPathComponent(Self.fileName)
    }

    init(containerURL: URL) {
        self.containerURL = containerURL
    }

    func read() -> StepikWidgetToken? {
        do {
            let unarchivedData = try Data(contentsOf: self.archiveURL)
            let token = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedData) as? StepikWidgetToken

            return token
        } catch {
            print("StepikWidgetTokenFileManager :: failed read with error = \(error)")
            return nil
        }
    }

    func write(token: StepikWidgetToken) throws {
        let archivedData = try NSKeyedArchiver.archivedData(
            withRootObject: token,
            requiringSecureCoding: true
        )

        try archivedData.write(to: self.archiveURL, options: .atomicWrite)
    }
}
