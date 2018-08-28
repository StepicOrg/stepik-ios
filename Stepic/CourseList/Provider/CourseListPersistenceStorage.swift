//
//  CourseListPersistenceStorage.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseListPersistenceStorage: class {
    func update(newCachedList: [Course.IdType])
    func getCoursesList() -> [Course.IdType]
}

final class DefaultsCourseListPersistenceStorage: CourseListPersistenceStorage {
    private let cacheID: String

    init(cacheID: String) {
        self.cacheID = cacheID
    }

    func getCoursesList() -> [Course.IdType] {
        return UserDefaults.standard.object(forKey: self.cacheID) as? [Course.IdType] ?? []
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

    func update(newCachedList: [Course.IdType]) {

    }

    func getCoursesList() -> [Course.IdType] {
        return list
    }
}
