import CoreData
import Foundation

final class Announcement: NSManagedObject, ManagedObject {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedSentDate), ascending: false)]
    }

    var status: AnnouncementStatus? { AnnouncementStatus(rawValue: self.statusString) }
}
