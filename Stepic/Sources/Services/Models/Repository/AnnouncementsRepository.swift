import Foundation
import PromiseKit

protocol AnnouncementsRepositoryProtocol: AnyObject {
    func fetch(
        courseID: Course.IdType,
        page: Int,
        dataSourceType: DataSourceType
    ) -> Promise<([AnnouncementPlainObject], Meta)>
    func fetch(
        ids: [Announcement.IdType],
        courseID: Course.IdType,
        dataSourceType: DataSourceType
    ) -> Promise<([AnnouncementPlainObject], Meta)>
}

extension AnnouncementsRepositoryProtocol {
    func fetch(courseID: Course.IdType, dataSourceType: DataSourceType) -> Promise<([AnnouncementPlainObject], Meta)> {
        self.fetch(courseID: courseID, page: 1, dataSourceType: dataSourceType)
    }
}

final class AnnouncementsRepository: AnnouncementsRepositoryProtocol {
    private let announcementsNetworkService: AnnouncementsNetworkServiceProtocol
    private let announcementsPersistenceService: AnnouncementsPersistenceServiceProtocol

    init(
        announcementsNetworkService: AnnouncementsNetworkServiceProtocol,
        announcementsPersistenceService: AnnouncementsPersistenceServiceProtocol
    ) {
        self.announcementsNetworkService = announcementsNetworkService
        self.announcementsPersistenceService = announcementsPersistenceService
    }

    func fetch(
        courseID: Course.IdType,
        page: Int,
        dataSourceType: DataSourceType
    ) -> Promise<([AnnouncementPlainObject], Meta)> {
        switch dataSourceType {
        case .cache:
            return self.announcementsPersistenceService
                .fetch(courseID: courseID)
                .map { ($0.map(\.plainObject), Meta.oneAndOnlyPage) }
        case .remote:
            return self.announcementsNetworkService
                .fetch(courseID: courseID, page: page)
                .then { remoteAnnouncements, meta in
                    self.announcementsPersistenceService
                        .save(announcements: remoteAnnouncements, forCourseWithID: courseID)
                        .map { (remoteAnnouncements, meta) }
                }
        }
    }

    func fetch(
        ids: [Announcement.IdType],
        courseID: Course.IdType,
        dataSourceType: DataSourceType
    ) -> Promise<([AnnouncementPlainObject], Meta)> {
        switch dataSourceType {
        case .cache:
            return self.announcementsPersistenceService
                .fetch(ids: ids)
                .map { ($0.map(\.plainObject), Meta.oneAndOnlyPage) }
        case .remote:
            return self.announcementsNetworkService
                .fetch(ids: ids)
                .then { remoteAnnouncements, meta in
                    self.announcementsPersistenceService
                        .save(announcements: remoteAnnouncements, forCourseWithID: courseID)
                        .map { (remoteAnnouncements, meta) }
                }
        }
    }
}

extension AnnouncementsRepository {
    static var `default`: AnnouncementsRepository {
        AnnouncementsRepository(
            announcementsNetworkService: AnnouncementsNetworkService(announcementsAPI: AnnouncementsAPI()),
            announcementsPersistenceService: AnnouncementsPersistenceService()
        )
    }
}
