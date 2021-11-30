import Foundation
import PromiseKit

protocol CourseListPersistenceServiceProtocol: AnyObject {
    func fetch() -> Promise<[Course]>
    func update(newCachedList: [Course])
}

class CourseListPersistenceService: CourseListPersistenceServiceProtocol {
    fileprivate let storage: CourseListPersistenceStorage
    fileprivate let coursesPersistenceService: CoursesPersistenceServiceProtocol

    init(
        storage: CourseListPersistenceStorage,
        coursesPersistenceService: CoursesPersistenceServiceProtocol = CoursesPersistenceService()
    ) {
        self.storage = storage
        self.coursesPersistenceService = coursesPersistenceService
    }

    func fetch() -> Promise<[Course]> {
        let courseListIDs = self.storage.getCoursesList()
        return self.fetchUniqueCourses(ids: courseListIDs)
    }

    func update(newCachedList: [Course]) {
        let ids = newCachedList.map { $0.id }
        self.storage.update(newCachedList: ids)
    }

    fileprivate func fetchUniqueCourses(ids: [Course.IdType]) -> Promise<[Course]> {
        self.coursesPersistenceService.fetch(ids: ids).map { courses -> [Course] in
            var uniqueCourses = [Course]()
            for course in courses {
                if !uniqueCourses.contains(where: { $0.id == course.id }) {
                    uniqueCourses.append(course)
                }
            }

            let result = uniqueCourses.reordered(order: ids, transform: { $0.id })

            return result
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

// MARK: - VisitedCourseListPersistenceServiceProtocol: CourseListPersistenceServiceProtocol -

protocol VisitedCourseListPersistenceServiceProtocol: CourseListPersistenceServiceProtocol {
    func insert(course: Course)
}

final class VisitedCourseListPersistenceService: CourseListPersistenceService {
    private lazy var orderedSet = NSMutableOrderedSet(array: self.storage.getCoursesList())

    override func update(newCachedList: [Course]) {
        self.orderedSet.removeAllObjects()
        self.orderedSet.addObjects(from: newCachedList.map(\.id))
        self.updateStorageUsingCurrentData()
    }

    private func updateStorageUsingCurrentData() {
        let ids = self.orderedSet.array as? [Course.IdType] ?? []
        self.storage.update(newCachedList: ids)
    }
}

extension VisitedCourseListPersistenceService: VisitedCourseListPersistenceServiceProtocol {
    private static let maxCount = 20

    func insert(course: Course) {
        if self.orderedSet.contains(course.id) {
            self.orderedSet.remove(course.id)
        }

        self.orderedSet.insert(course.id, at: 0)

        if self.orderedSet.count > Self.maxCount {
            let lastIndex = self.orderedSet.count - 1
            self.orderedSet.removeObject(at: lastIndex)
        }

        self.updateStorageUsingCurrentData()
    }
}

// MARK: - DownloadedCourseListPersistenceService: CourseListPersistenceService -

final class DownloadedCourseListPersistenceService: CourseListPersistenceService {
    private let downloadsProvider: DownloadsProviderProtocol

    init(downloadsProvider: DownloadsProviderProtocol = DownloadsProvider.default) {
        self.downloadsProvider = downloadsProvider
        super.init(storage: PassiveCourseListPersistenceStorage(cachedList: []))
    }

    override func fetch() -> Promise<[Course]> {
        self.downloadsProvider.fetchCachedCourses().then { courses -> Promise<[Course]> in
            let resultCourses = courses.filter(\.enrolled).sorted { $0.id < $1.id }
            return .value(resultCourses)
        }
    }

    override func update(newCachedList: [Course]) {}
}

// MARK: - WishlistCourseListPersistenceService: CourseListPersistenceService -

final class WishlistCourseListPersistenceService: CourseListPersistenceService {
    private let wishlistEntriesPersistenceService: WishlistEntriesPersistenceServiceProtocol

    init(wishlistEntriesPersistenceService: WishlistEntriesPersistenceServiceProtocol) {
        self.wishlistEntriesPersistenceService = wishlistEntriesPersistenceService
        super.init(storage: PassiveCourseListPersistenceStorage(cachedList: []))
    }

    override func fetch() -> Promise<[Course]> {
        self.wishlistEntriesPersistenceService
            .fetchAll()
            .mapValues(\.courseID)
            .then(self.fetchUniqueCourses(ids:))
    }

    override func update(newCachedList: [Course]) {}
}
