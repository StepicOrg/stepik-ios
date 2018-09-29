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

// REVIEW: class?
final class EnrolledCourseListType: CourseListType {

}

final class TagCourseListType: CourseListType {
    let id: Int
    let language: ContentLanguage

    init(id: Int, language: ContentLanguage) {
        self.id = id
        self.language = language
    }
}

final class CollectionCourseListType: CourseListType {
    let ids: [Course.IdType]

    init(ids: [Course.IdType]) {
        self.ids = ids
    }
}

final class SearchResultCourseListType: CourseListType {
    let query: String
    let language: ContentLanguage

    init(query: String, language: ContentLanguage) {
        self.query = query
        self.language = language
    }
}

// MARK: - Services factory

final class CourseListServicesFactory {
    let type: CourseListType
    private let coursesAPI: CoursesAPI
    private let userCoursesAPI: UserCoursesAPI
    private let searchResultsAPI: SearchResultsAPI

    init(
        type: CourseListType,
        coursesAPI: CoursesAPI,
        userCoursesAPI: UserCoursesAPI,
        searchResultsAPI: SearchResultsAPI
    ) {
        self.type = type
        self.coursesAPI = coursesAPI
        self.userCoursesAPI = userCoursesAPI
        self.searchResultsAPI = searchResultsAPI
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
        } else if let _ = self.type as? SearchResultCourseListType {
            return nil
        } else {
            fatalError("Unsupported course list type")
        }
    }

    func makeNetworkService() -> CourseListNetworkServiceProtocol {
        if let type = self.type as? EnrolledCourseListType {
            return EnrolledCourseListNetworkService(
                type: type,
                coursesAPI: self.coursesAPI,
                userCoursesAPI: self.userCoursesAPI
            )
        } else if let type = self.type as? PopularCourseListType {
            return PopularCourseListNetworkService(type: type, coursesAPI: self.coursesAPI)
        } else if let type = self.type as? TagCourseListType {
            return TagCourseListNetworkService(type: type, coursesAPI: self.coursesAPI)
        } else if let type = self.type as? CollectionCourseListType {
            return CollectionCourseListNetworkService(type: type, coursesAPI: self.coursesAPI)
        } else if let type = self.type as? SearchResultCourseListType {
            return SearchResultCourseListNetworkService(
                type: type,
                coursesAPI: self.coursesAPI,
                searchResultsAPI: self.searchResultsAPI
            )
        } else {
            fatalError("Unsupported course list type")
        }
    }
}
