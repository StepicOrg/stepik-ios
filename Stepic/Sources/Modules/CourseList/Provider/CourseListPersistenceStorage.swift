import Foundation

protocol CourseListPersistenceStorage: AnyObject {
    func update(newCachedList: [Course.IdType])
    func getCoursesList() -> [Course.IdType]
}

final class DefaultsCourseListPersistenceStorage: CourseListPersistenceStorage {
    private let cacheID: String

    init(cacheID: String) {
        self.cacheID = cacheID
    }

    func getCoursesList() -> [Course.IdType] {
        UserDefaults.standard.object(forKey: self.cacheID) as? [Course.IdType] ?? []
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
