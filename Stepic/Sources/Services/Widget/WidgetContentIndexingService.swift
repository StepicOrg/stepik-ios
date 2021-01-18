import Foundation
import PromiseKit
import WidgetKit

protocol WidgetContentIndexingServiceProtocol: AnyObject {
    func startIndexing(force: Bool)
    func stopIndexing()
    func indexUserCourses() -> Promise<Void>
}

extension WidgetContentIndexingServiceProtocol {
    func startIndexing() {
        self.startIndexing(force: false)
    }
}

@available(iOS 14.0, *)
final class WidgetContentIndexingService: WidgetContentIndexingServiceProtocol {
    private static let startIndexingDelay: TimeInterval = 1.5

    private typealias UserCoursesData = (courses: [Course], progresses: [Progress], coversData: [Data?])

    private let widgetContentFileManager: WidgetContentFileManagerProtocol
    private let userAccountService: UserAccountServiceProtocol
    private let userCoursesNetworkService: UserCoursesNetworkServiceProtocol
    private let userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol
    private let usersNetworkService: UsersNetworkServiceProtocol
    private let courseCoverPreheater: ImagePreheaterProtocol
    private let courseCoverImageDataProviderFactory: (URL) -> ImageDataProvider
    private let dataBackUpdateService: DataBackUpdateServiceProtocol
    private let coreDataHelper: CoreDataHelper

    private weak var indexingTimer: Timer?
    private let courseProgressUpdatedDebouncer = Debouncer(
        delay: WidgetContentIndexingService.courseProgressUpdateDebounceInterval
    )

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
        dataBackUpdateService: DataBackUpdateServiceProtocol,
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

        self.dataBackUpdateService = dataBackUpdateService
        self.dataBackUpdateService.delegate = self
    }

    deinit {
        self.removeObservers()
        self.stopIndexingTimer()
    }

    func startIndexing(force: Bool) {
        self.addObservers()
        self.scheduleIndexingTimer()
        self.indexContent(forceIndex: force)
    }

    func stopIndexing() {
        self.removeObservers()
        self.stopIndexingTimer()
    }

    func indexUserCourses() -> Promise<Void> {
        guard self.userAccountService.isAuthorized else {
            return self.widgetContentFileManager.writeUserCourses([])
        }

        return self.fetchRemoteUserCoursesData().then { courses, progresses, coversData in
            self.writeUserCoursesData(courses: courses, progresses: progresses, coversData: coversData)
        }
    }

    // MARK: - Private API

    @objc
    private func indexContent(forceIndex: Bool = false) {
        guard forceIndex || self.shouldIndexContent else {
            return
        }

        firstly {
            after(seconds: Self.startIndexingDelay)
        }.then {
            self.indexUserCourses()
        }.done {
            self.lastDateIndexCompleted = Date()
            WidgetCenter.shared.reloadAllTimelines()
        }.catch { error in
            print("WidgetContentIndexingService :: failed index with error = \(error)")
        }
    }

    // MARK: Fetch Data

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

    // MARK: NotificationCenter

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleUserAccountDidChange),
            name: .didLogout,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleUserAccountDidChange),
            name: .didChangeCurrentUser,
            object: nil
        )
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func handleUserAccountDidChange() {
        self.indexContent(forceIndex: true)
    }

    // MARK: Timer

    private func scheduleIndexingTimer() {
        self.indexingTimer?.invalidate()
        self.indexingTimer = Timer.scheduledTimer(
            timeInterval: Self.fiveMinutesInterval,
            target: self,
            selector: #selector(self.indexContent),
            userInfo: nil,
            repeats: true
        )
    }

    private func stopIndexingTimer() {
        self.indexingTimer?.invalidate()
        self.indexingTimer = nil
    }
}

@available(iOS 14.0, *)
extension WidgetContentIndexingService {
    static let `default` = WidgetContentIndexingService(
        widgetContentFileManager: WidgetContentFileManager(containerURL: FileManager.widgetContainerURL),
        userAccountService: UserAccountService(),
        userCoursesNetworkService: UserCoursesNetworkService(userCoursesAPI: UserCoursesAPI()),
        userCoursesPersistenceService: UserCoursesPersistenceService(),
        coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
        coursesPersistenceService: CoursesPersistenceService(),
        progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
        usersNetworkService: UsersNetworkService(usersAPI: UsersAPI()),
        dataBackUpdateService: DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )
    )
}

// MARK: - WidgetContentIndexingService: DataBackUpdateServiceDelegate -

@available(iOS 14.0, *)
extension WidgetContentIndexingService: DataBackUpdateServiceDelegate {
    private static let courseProgressUpdateDebounceInterval: TimeInterval = 15

    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport update: DataBackUpdateDescription,
        for target: DataBackUpdateTarget
    ) {
        guard case .course = target,
              update.contains(.progress) else {
            return
        }

        self.courseProgressUpdatedDebouncer.action = { [weak self] in
            self?.indexContent(forceIndex: true)
        }
    }

    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        didReport refreshedTarget: DataBackUpdateTarget
    ) {}
}


// MARK: - WidgetContentIndexingService (UserDefaults) -

@available(iOS 14.0, *)
extension WidgetContentIndexingService {
    private static let fiveMinutesInterval: TimeInterval = 300
    private static let lastDateIndexCompletedKey = "lastDateWidgetContentIndexCompletedKey"

    private var shouldIndexContent: Bool {
        Date().timeIntervalSince(self.lastDateIndexCompleted) >= Self.fiveMinutesInterval
    }

    fileprivate var lastDateIndexCompleted: Date {
        get {
            if let userDefaultsDate = UserDefaults.standard.object(forKey: Self.lastDateIndexCompletedKey) as? Date {
                return userDefaultsDate
            } else {
                return Date(timeIntervalSince1970: 0)
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.lastDateIndexCompletedKey)
        }
    }
}
