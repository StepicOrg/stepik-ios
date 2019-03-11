import Foundation

// MARK: - Course types

protocol CourseListType {
    // It's just a marker
}

struct PopularCourseListType: CourseListType {
    let language: ContentLanguage
}

struct EnrolledCourseListType: CourseListType {
}

struct TagCourseListType: CourseListType {
    let id: Int
    let language: ContentLanguage
}

struct CollectionCourseListType: CourseListType {
    let ids: [Course.IdType]
}

struct SearchResultCourseListType: CourseListType {
    let query: String
    let language: ContentLanguage
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
        if self.type is EnrolledCourseListType {
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
        } else if self.type is TagCourseListType {
            return nil
        } else if let type = self.type as? CollectionCourseListType {
            return CourseListPersistenceService(
                storage: PassiveCourseListPersistenceStorage(
                    cachedList: type.ids
                )
            )
        } else if self.type is SearchResultCourseListType {
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
