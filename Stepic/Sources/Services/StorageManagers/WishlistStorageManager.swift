import Foundation

protocol WishlistStorageManagerProtocol: AnyObject {
    var coursesIDs: [Course.IdType] { get set }
}

final class WishlistStorageManager: WishlistStorageManagerProtocol {
    var coursesIDs: [Course.IdType] {
        get {
            UserDefaults.standard.array(forKey: Key.wishlistCoursesIDs.rawValue) as? [Course.IdType] ?? []
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Key.wishlistCoursesIDs.rawValue)
        }
    }

    private enum Key: String {
        case wishlistCoursesIDs
    }
}
