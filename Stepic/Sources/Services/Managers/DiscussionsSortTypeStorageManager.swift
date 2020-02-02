import Foundation

protocol DiscussionsSortTypeStorageManagerProtocol: AnyObject {
    var globalDiscussionsSortType: Discussions.SortType { get set }
}

final class DiscussionsSortTypeStorageManager: DiscussionsSortTypeStorageManagerProtocol {
    var globalDiscussionsSortType: Discussions.SortType {
        get {
            if let stringValue = UserDefaults.standard.string(forKey: Key.discussionsSortType.rawValue),
               let sortType = Discussions.SortType(rawValue: stringValue) {
                return sortType
            } else {
                return .last
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.discussionsSortType.rawValue)
        }
    }

    private enum Key: String {
        case discussionsSortType = "discussionsSortTypeKey"
    }
}
