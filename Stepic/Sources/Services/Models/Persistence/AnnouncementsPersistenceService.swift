import Foundation
import PromiseKit

protocol AnnouncementsPersistenceServiceProtocol: AnyObject {
    func fetch(id: Announcement.IdType) -> Guarantee<Announcement?>
    func fetch(ids: [Announcement.IdType]) -> Guarantee<[Announcement]>
    func fetch(courseID: Course.IdType) -> Guarantee<[Announcement]>
    func save(announcements: [AnnouncementPlainObject], forCourseWithID courseID: Course.IdType) -> Guarantee<Void>
}

final class AnnouncementsPersistenceService: BasePersistenceService<Announcement>,
                                             AnnouncementsPersistenceServiceProtocol {
    func fetch(courseID: Course.IdType) -> Guarantee<[Announcement]> {
        Guarantee { seal in
            let request = Announcement.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(Announcement.managedCourseId),
                NSNumber(value: courseID)
            )
            request.returnsObjectsAsFaults = false

            do {
                let announcements = try self.managedObjectContext.fetch(request)
                seal(announcements)
            } catch {
                print("AnnouncementsPersistenceService :: \(#function) failed fetch with error = \(error)")
                seal([])
            }
        }
    }

    func save(announcements: [AnnouncementPlainObject], forCourseWithID courseID: Course.IdType) -> Guarantee<Void> {
        if announcements.isEmpty {
            return .value(())
        }

        #if DEBUG
        let announcementsCoursesIDs = Set(announcements.map(\.courseID))
        assert(announcementsCoursesIDs == Set([courseID]))
        #endif

        return Guarantee { seal in
            self.fetch(ids: announcements.map(\.id)).done { cachedAnnouncements in
                let cachedAnnouncementsMap = Dictionary(uniqueKeysWithValues: cachedAnnouncements.map({ ($0.id, $0) }))
                let course = Course.findOrFetch(in: self.managedObjectContext, byID: courseID)

                self.managedObjectContext.performChanges {
                    for announcementToSave in announcements {
                        let resultAnnouncement: Announcement

                        if let cachedAnnouncement = cachedAnnouncementsMap[announcementToSave.id] {
                            cachedAnnouncement.update(announcement: announcementToSave)
                            resultAnnouncement = cachedAnnouncement
                        } else {
                            resultAnnouncement = Announcement.insert(
                                into: self.managedObjectContext,
                                announcement: announcementToSave
                            )
                        }

                        if let userID = announcementToSave.userID {
                            resultAnnouncement.user = User.findOrFetch(in: self.managedObjectContext, byID: userID)
                        }

                        resultAnnouncement.course = course
                    }

                    seal(())
                }
            }
        }
    }
}
