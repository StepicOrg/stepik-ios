//
//  CourseListTypes.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

// MARK: - Course types

protocol CourseListType {
    // It's just a marker
}

struct PopularCourseListType: CourseListType {
    let language: ContentLanguage
}

final class EnrolledCourseListType: CourseListType {

}

final class TagCourseListType: CourseListType {
    var id: Int
    var language: ContentLanguage

    init(id: Int, language: ContentLanguage) {
        self.id = id
        self.language = language
    }
}

final class CollectionCourseListType: CourseListType {
    var ids: [Course.IdType]

    init(ids: [Course.IdType]) {
        self.ids = ids
    }
}

// MARK: - Services factory

final class CourseListServicesFactory {
    let type: CourseListType
    private let coursesAPI: CoursesAPI

    init(type: CourseListType, coursesAPI: CoursesAPI) {
        self.type = type
        self.coursesAPI = coursesAPI
    }

    func makePersistenceService() -> CourseListPersistenceServiceProtocol? {
        if let _ = self.type as? EnrolledCourseListType {
            return CourseListPersistenceService(
                storage: DefaultsCourseListPersistenceStorage(
                    cacheID: "MyCoursesInfo"
                )
            )
        } else if let type = self.type as? PopularCourseListType {
            return CourseListPersistenceService(
                storage: DefaultsCourseListPersistenceStorage(
                    cacheID: "PopularCoursesInfo_\(type.language.languageString)"
                )
            )
        } else if let _ = self.type as? TagCourseListType {
            return nil
        } else if let type = self.type as? CollectionCourseListType {
            return CourseListPersistenceService(
                storage: PassiveCourseListPersistenceStorage(
                    cachedList: type.ids
                )
            )
        } else {
            fatalError("Unsupported course list type")
        }
    }

    func makeNetworkService() -> CourseListNetworkServiceProtocol {
        if let type = self.type as? EnrolledCourseListType {
            return EnrolledCourseListNetworkService(type: type, coursesAPI: self.coursesAPI)
        } else if let type = self.type as? PopularCourseListType {
            return PopularCourseListNetworkService(type: type, coursesAPI: self.coursesAPI)
        } else if let type = self.type as? TagCourseListType {
            return TagCourseListNetworkService(type: type, coursesAPI: self.coursesAPI)
        } else if let type = self.type as? CollectionCourseListType {
            return CollectionCourseListNetworkService(type: type, coursesAPI: self.coursesAPI)
        } else {
            fatalError("Unsupported course list type")
        }
    }
}
