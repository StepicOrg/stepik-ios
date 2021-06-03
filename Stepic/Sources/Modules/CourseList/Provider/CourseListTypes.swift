import Foundation

// MARK: - Course types

protocol CourseListType {
    // It's just a marker
    var analyticName: String { get }
}

struct PopularCourseListType: CourseListType {
    let language: ContentLanguage

    var analyticName: String { "popular_course_list" }
}

struct EnrolledCourseListType: CourseListType {
    var analyticName: String { "enrolled_course_list" }
}

struct FavoriteCourseListType: CourseListType {
    var analyticName: String { "favorite_course_list" }
}

struct ArchivedCourseListType: CourseListType {
    var analyticName: String { "archived_course_list" }
}

struct TagCourseListType: CourseListType {
    let id: Int
    let language: ContentLanguage

    var analyticName: String { "tag_course_list" }
}

struct CollectionCourseListType: CourseListType {
    let ids: [Course.IdType]

    var analyticName: String { "collection_course_list" }
}

struct SearchResultCourseListType: CourseListType {
    let query: String
    let filterQuery: CourseListFilterQuery?
    let language: ContentLanguage

    var analyticName: String { "search_result_course_list" }
}

struct TeacherCourseListType: CourseListType {
    let teacherID: User.IdType

    var analyticName: String { "teacher_course_list" }
}

struct VisitedCourseListType: CourseListType {
    var analyticName: String { "visited_course_list" }
}

struct DeepLinkCourseListType: CourseListType {
    let ids: [Course.IdType]

    var analyticName: String { "deep_link_course_list" }
}

struct CatalogBlockCourseListType: CourseListType {
    let courseListID: CourseListModel.IdType
    let coursesIDs: [Course.IdType]

    var analyticName: String { "catalog_block_course_list" }
}

struct RecommendationsCourseListType: CourseListType {
    let id: CourseListModel.IdType
    let language: ContentLanguage
    let platform: PlatformType

    var analyticName: String { "recommendations_course_list" }
}

struct WishlistCourseListType: CourseListType {
    let ids: [Course.IdType]

    var analyticName: String { "wishlist_course_list" }
}

// MARK: - Services factory

final class CourseListServicesFactory {
    let type: CourseListType
    private let coursesAPI: CoursesAPI
    private let userCoursesAPI: UserCoursesAPI
    private let searchResultsAPI: SearchResultsAPI
    private let visitedCoursesAPI: VisitedCoursesAPI
    private let courseListsAPI: CourseListsAPI
    private let courseRecommendationsAPI: CourseRecommendationsAPI

    init(
        type: CourseListType,
        coursesAPI: CoursesAPI = CoursesAPI(),
        userCoursesAPI: UserCoursesAPI = UserCoursesAPI(),
        searchResultsAPI: SearchResultsAPI = SearchResultsAPI(),
        visitedCoursesAPI: VisitedCoursesAPI = VisitedCoursesAPI(),
        courseListsAPI: CourseListsAPI = CourseListsAPI(),
        courseRecommendationsAPI: CourseRecommendationsAPI = CourseRecommendationsAPI()
    ) {
        self.type = type
        self.coursesAPI = coursesAPI
        self.userCoursesAPI = userCoursesAPI
        self.searchResultsAPI = searchResultsAPI
        self.visitedCoursesAPI = visitedCoursesAPI
        self.courseListsAPI = courseListsAPI
        self.courseRecommendationsAPI = courseRecommendationsAPI
    }

    func makePersistenceService() -> CourseListPersistenceServiceProtocol? {
        if self.type is EnrolledCourseListType {
            return CourseListPersistenceService(
                storage: DefaultsCourseListPersistenceStorage(
                    cacheID: "MyCoursesInfo"
                )
            )
        } else if self.type is FavoriteCourseListType {
            return CourseListPersistenceService(
                storage: DefaultsCourseListPersistenceStorage(
                    cacheID: "MyCoursesInfoFavorite"
                )
            )
        } else if self.type is ArchivedCourseListType {
            return CourseListPersistenceService(
                storage: DefaultsCourseListPersistenceStorage(
                    cacheID: "MyCoursesInfoArchived"
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
        } else if let type = self.type as? TeacherCourseListType {
            return CourseListPersistenceService(
                storage: CreatedCoursesCourseListPersistenceStorage(teacherID: type.teacherID)
            )
        } else if self.type is VisitedCourseListType {
            return VisitedCourseListPersistenceService(
                storage: DefaultsCourseListPersistenceStorage(cacheID: "VisitedCoursesInfo")
            )
        } else if let type = self.type as? DeepLinkCourseListType {
            return CourseListPersistenceService(
                storage: PassiveCourseListPersistenceStorage(
                    cachedList: type.ids
                )
            )
        } else if let type = self.type as? CatalogBlockCourseListType {
            return CourseListPersistenceService(
                storage: DefaultsCourseListPersistenceStorage(
                    cacheID: "CatalogBlockInfo_\(type.courseListID)",
                    defaultCoursesList: type.coursesIDs
                )
            )
        } else if let type = self.type as? RecommendationsCourseListType {
            return CourseListPersistenceService(
                storage: DefaultsCourseListPersistenceStorage(
                    cacheID: "RecommendedCourses_\(type.id)_\(type.language.languageString)_\(type.platform.stringValue)"
                )
            )
        } else if let type = self.type as? WishlistCourseListType {
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
        if self.type is EnrolledCourseListType
            || self.type is FavoriteCourseListType
            || self.type is ArchivedCourseListType {
            return UserCoursesCourseListNetworkService(
                type: self.type,
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
        } else if let type = self.type as? TeacherCourseListType {
            return TeacherCourseListNetworkService(type: type, coursesAPI: self.coursesAPI)
        } else if let type = self.type as? VisitedCourseListType {
            return VisitedCourseListNetworkService(
                type: type,
                coursesAPI: self.coursesAPI,
                visitedCoursesAPI: self.visitedCoursesAPI
            )
        } else if let type = self.type as? DeepLinkCourseListType {
            return DeepLinkCourseListNetworkService(type: type, coursesAPI: self.coursesAPI)
        } else if let type = self.type as? CatalogBlockCourseListType {
            return CatalogBlockCourseListNetworkService(
                type: type,
                coursesAPI: self.coursesAPI,
                courseListsAPI: self.courseListsAPI
            )
        } else if let type = self.type as? RecommendationsCourseListType {
            return RecommendationsCourseListNetworkService(
                type: type,
                coursesAPI: self.coursesAPI,
                courseRecommendationsNetworkService: CourseRecommendationsNetworkService(
                    courseRecommendationsAPI: self.courseRecommendationsAPI
                )
            )
        } else if let type = self.type as? WishlistCourseListType {
            return WishlistCourseListNetworkService(
                type: type,
                coursesAPI: self.coursesAPI
            )
        } else {
            fatalError("Unsupported course list type")
        }
    }
}
