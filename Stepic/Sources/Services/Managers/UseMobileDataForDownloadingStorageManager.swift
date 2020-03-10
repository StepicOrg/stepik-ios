import Foundation

protocol UseMobileDataForDownloadingStorageManagerProtocol: AnyObject {
    var shouldUseMobileDataForDownloading: Bool { get set }
}

final class UseMobileDataForDownloadingStorageManager: UseMobileDataForDownloadingStorageManagerProtocol {
    var shouldUseMobileDataForDownloading: Bool {
        get {
            UserDefaults.standard.bool(forKey: Key.useMobileDataForDownloading.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.useMobileDataForDownloading.rawValue)
        }
    }

    private enum Key: String {
        case useMobileDataForDownloading
    }
}
