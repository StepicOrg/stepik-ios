//
//  CourseListTypes.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseListType {
    // It's just a marker
}

protocol PersistableCourseListTypeProtocol {
    var storage: CourseListPersistenceStorage { get }
}

final class PopularCourseListType: CourseListType, PersistableCourseListTypeProtocol {
    private lazy var _storage: CourseListPersistenceStorage = DefaultsCourseListPersistenceStorage(
        cacheID: "PopularCoursesInfo_\(self.language.languageString)"
    )
    var storage: CourseListPersistenceStorage {
        return self._storage
    }

    var language: ContentLanguage

    init(language: ContentLanguage) {
        self.language = language
    }
}

final class EnrolledCourseListType: CourseListType, PersistableCourseListTypeProtocol {
    private lazy var _storage: CourseListPersistenceStorage = DefaultsCourseListPersistenceStorage(
        cacheID: "MyCoursesInfo"
    )
    var storage: CourseListPersistenceStorage {
        return self._storage
    }
}

final class TagCourseListType: CourseListType {
    var id: Int
    var language: ContentLanguage

    init(id: Int, language: ContentLanguage) {
        self.id = id
        self.language = language
    }
}

final class CollectionCourseListType: CourseListType, PersistableCourseListTypeProtocol {
    private lazy var _storage: CourseListPersistenceStorage = PassiveCourseListPersistenceStorage(
        cachedList: self.ids
    )
    var storage: CourseListPersistenceStorage {
        return self._storage
    }

    var ids: [Course.IdType]

    init(ids: [Course.IdType]) {
        self.ids = ids
    }
}
