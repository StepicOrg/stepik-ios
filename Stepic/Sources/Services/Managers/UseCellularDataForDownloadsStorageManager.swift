import Foundation

protocol UseCellularDataForDownloadsStorageManagerProtocol: AnyObject {
    var shouldUseCellularDataForDownloads: Bool { get set }
}

final class UseCellularDataForDownloadsStorageManager: UseCellularDataForDownloadsStorageManagerProtocol {
    var shouldUseCellularDataForDownloads: Bool {
        get {
            UserDefaults.standard.bool(forKey: Key.useCellularDataForDownloads.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.useCellularDataForDownloads.rawValue)
        }
    }

    private enum Key: String {
        case useCellularDataForDownloads
    }
}
