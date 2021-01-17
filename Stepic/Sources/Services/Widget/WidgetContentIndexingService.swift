import Foundation
import PromiseKit
import WidgetKit

protocol WidgetContentIndexingServiceProtocol: AnyObject {
    func startIndexing()
    func stopIndexing()
    func indexUserCourses() -> Promise<Void>
}

final class WidgetContentIndexingService: WidgetContentIndexingServiceProtocol {
    private typealias UserCoursesData = (courses: [Course], progresses: [Progress], coversData: [Data?])

    private let widgetContentFileManager: WidgetContentFileManagerProtocol

    private let userAccountService: UserAccountServiceProtocol
    // UserCourses
    private let userCoursesNetworkService: UserCoursesNetworkServiceProtocol
    private let userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol
    // Courses
    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    // Progresses
    private let progressesNetworkService: ProgressesNetworkServiceProtocol
    // Users
    private let usersNetworkService: UsersNetworkServiceProtocol
    // CourseCover
    private let courseCoverPreheater: ImagePreheaterProtocol
    private let courseCoverImageDataProviderFactory: (URL) -> ImageDataProvider

    private let coreDataHelper: CoreDataHelper

    init(
        widgetContentFileManager: WidgetContentFileManagerProtocol,
        userAccountService: UserAccountServiceProtocol,
        userCoursesNetworkService: UserCoursesNetworkServiceProtocol,
        userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        usersNetworkService: UsersNetworkServiceProtocol,
        courseCoverPreheater: ImagePreheaterProtocol = NukeImagePreheater(),
        courseCoverImageDataProviderFactory: @escaping (URL) -> ImageDataProvider = { NukeImageDataProvider(url: $0) },
        coreDataHelper: CoreDataHelper = .shared
    ) {
        self.widgetContentFileManager = widgetContentFileManager
        self.userAccountService = userAccountService
        self.userCoursesNetworkService = userCoursesNetworkService
        self.userCoursesPersistenceService = userCoursesPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.usersNetworkService = usersNetworkService
        self.courseCoverPreheater = courseCoverPreheater
        self.courseCoverImageDataProviderFactory = courseCoverImageDataProviderFactory
        self.coreDataHelper = coreDataHelper
    }

    func startIndexing() {
        firstly {
            after(seconds: 1.5)
        }.then {
            self.indexUserCourses()
        }.done {
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }.catch { error in
            print(error)
        }
    }

    func stopIndexing() {
    }

    func indexUserCourses() -> Promise<Void> {
        guard self.userAccountService.isAuthorized else {
            return self.widgetContentFileManager.writeUserCourses([])
        }

        return self.fetchRemoteUserCoursesData().then { courses, progresses, coversData in
            self.writeUserCoursesData(courses: courses, progresses: progresses, coversData: coversData)
        }
    }

    private func fetchRemoteUserCoursesData() -> Promise<UserCoursesData> {
        Promise { seal in
            self.userCoursesNetworkService.fetch().then { userCourses, _ -> Promise<[Course]> in
                let coursesIDs = Array(
                    userCourses
                        .sorted(by: { $0.lastViewed > $1.lastViewed })
                        .map(\.courseID)
                        .prefix(WidgetSpec.maxUserCoursesCount)
                )

                return self.coursesNetworkService.fetch(ids: coursesIDs)
            }.then { courses -> Promise<([Course], [Progress])> in
                let progressIDs = courses.compactMap(\.progressId)

                assert(courses.count == progressIDs.count)

                return self.progressesNetworkService.fetch(ids: progressIDs).map { (courses, $0) }
            }.then { courses, progresses -> Guarantee<([Course], [Progress])> in
                for (course, progress) in zip(courses, progresses) {
                    assert(course.progressId == progress.id)
                    course.progress = progress
                }
                self.coreDataHelper.save()

                return self.fetchAuthorsIfNeeded(courses: courses).map { _ in (courses, progresses) }
            }.then { courses, progresses -> Guarantee<([Course], [Progress], [Data?])> in
                self.fetchCoversIfNeeded(courses: courses).map { (courses, progresses, $0) }
            }.done { courses, progresses, coversData in
                seal.fulfill((courses, progresses, coversData))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func fetchAuthorsIfNeeded(courses: [Course]) -> Guarantee<Void> {
        let allAuthorsIDs = Set(
            courses.reduce(into: [Int]()) { result, course in
                result.append(contentsOf: course.authorsArray)
            }
        )
        let persistedAuthorsIDs = Set(
            courses.reduce(into: [Int]()) { result, course in
                result.append(contentsOf: course.authors.map(\.id))
            }
        )
        let authorsIDsToFetch = Array(allAuthorsIDs.subtracting(persistedAuthorsIDs))

        if authorsIDsToFetch.isEmpty {
            return .value(())
        }

        return Guarantee { seal in
            self.usersNetworkService.fetch(ids: authorsIDsToFetch).done { authors in
                let authorsMap = Dictionary(uniqueKeysWithValues: authors.map { ($0.id, $0) })

                for course in courses {
                    let fetchedAuthors = course.authorsArray.compactMap { authorsMap[$0] }

                    if fetchedAuthors.isEmpty {
                        continue
                    }

                    for author in fetchedAuthors {
                        if let index = course.authors.firstIndex(where: { $0.id == author.id }) {
                            course.authors[index] = author
                        } else {
                            course.authors.append(author)
                        }
                    }

                    course.authors = course.authors.reordered(order: course.authorsArray, transform: { $0.id })
                }

                self.coreDataHelper.save()

                seal(())
            }.catch { _ in
                seal(())
            }
        }
    }

    private func fetchCoversIfNeeded(courses: [Course]) -> Guarantee<[Data?]> {
        let allCoversURLs = Set(
            courses.compactMap { course -> URL? in
                guard let imageURLString = course.managedImageURL,
                      let url = URL(string: imageURLString) else {
                    return nil
                }

                return url
            }
        )
        let coversURLsToFetch = Array(
            allCoversURLs.filter { url -> Bool in
                let provider = self.courseCoverImageDataProviderFactory(url)
                return provider.data == nil
            }
        )

        return self.courseCoverPreheater.preheat(urls: coversURLsToFetch).then { _ -> Guarantee<[Data?]> in
            let coversData = courses.map { course -> Data? in
                guard let coverURLString = course.managedImageURL,
                      let coverURL = URL(string: coverURLString) else {
                    return nil
                }

                let provider = self.courseCoverImageDataProviderFactory(coverURL)

                return provider.data
            }

            return .value(coversData)
        }
    }

    private func writeUserCoursesData(courses: [Course], progresses: [Progress], coversData: [Data?]) -> Promise<Void> {
        assert(courses.count == progresses.count && courses.count == coversData.count)

        let widgetUserCourses = courses.enumerated().map { (index, course) -> WidgetUserCourse in
            let subtitle: String = {
                var formattedAuthorsString = course.authors
                    .map(\.fullName)
                    .reduce(into: "") { result, fullName in
                        result += "\(fullName), "
                    }
                    .trimmed()

                if !formattedAuthorsString.isEmpty {
                    formattedAuthorsString.removeLast()
                    formattedAuthorsString = formattedAuthorsString.trimmed()
                }

                return formattedAuthorsString.isEmpty
                    ? course.summary
                    : "\(NSLocalizedString("CourseInfoTitleAuthor", comment: "")) \(formattedAuthorsString)"
            }()

            return WidgetUserCourse(
                id: course.id,
                title: course.title,
                subtitle: subtitle,
                progress: progresses[index].percentPassed,
                thumbnailData: coversData[index]
            )
        }

        return self.widgetContentFileManager.writeUserCourses(widgetUserCourses)
    }
}

extension WidgetContentIndexingService {
    static let `default` = WidgetContentIndexingService(
        widgetContentFileManager: WidgetContentFileManager(containerURL: FileManager.widgetContainerURL),
        userAccountService: UserAccountService(),
        userCoursesNetworkService: UserCoursesNetworkService(userCoursesAPI: UserCoursesAPI()),
        userCoursesPersistenceService: UserCoursesPersistenceService(),
        coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
        coursesPersistenceService: CoursesPersistenceService(),
        progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
        usersNetworkService: UsersNetworkService(usersAPI: UsersAPI())
    )
}
