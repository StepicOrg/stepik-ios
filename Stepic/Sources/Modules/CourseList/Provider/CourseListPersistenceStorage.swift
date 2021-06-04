import Foundation

protocol CourseListPersistenceStorage: AnyObject {
    func update(newCachedList: [Course.IdType])
    func getCoursesList() -> [Course.IdType]
}

final class DefaultsCourseListPersistenceStorage: CourseListPersistenceStorage {
    private let cacheID: String
    private let defaultCoursesList: [Course.IdType]

    init(cacheID: String, defaultCoursesList: [Course.IdType] = []) {
        self.cacheID = cacheID
        self.defaultCoursesList = defaultCoursesList
    }

    func getCoursesList() -> [Course.IdType] {
        UserDefaults.standard.object(forKey: self.cacheID) as? [Course.IdType] ?? self.defaultCoursesList
    }

    func update(newCachedList: [Course.IdType]) {
        UserDefaults.standard.set(newCachedList, forKey: self.cacheID)
    }
}

final class PassiveCourseListPersistenceStorage: CourseListPersistenceStorage {
    private let list: [Int]

    init(cachedList: [Course.IdType]) {
        self.list = cachedList
    }

    func update(newCachedList: [Course.IdType]) {}

    func getCoursesList() -> [Course.IdType] { self.list }
}

final class CreatedCoursesCourseListPersistenceStorage: CourseListPersistenceStorage {
    private let teacherID: User.IdType

    private var teacherEntity: User? {
        User.fetchById(self.teacherID)?.first
    }

    init(teacherID: User.IdType) {
        self.teacherID = teacherID
    }

    func update(newCachedList: [Course.IdType]) {
        self.teacherEntity?.createdCoursesArray = newCachedList
    }

    func getCoursesList() -> [Course.IdType] {
        self.teacherEntity?.createdCoursesArray ?? []
    }
}

extension WishlistStorageManager: CourseListPersistenceStorage {
    func update(newCachedList: [Course.IdType]) {}

    func getCoursesList() -> [Course.IdType] { self.coursesIDs }
}
