import Foundation
import PromiseKit

protocol CourseListInteractorProtocol: AnyObject {
    func doCoursesFetch(request: CourseList.CoursesLoad.Request)
    func doNextCoursesFetch(request: CourseList.NextCoursesLoad.Request)
    func doPrimaryAction(request: CourseList.PrimaryCourseAction.Request)
    func doMainAction(request: CourseList.MainCourseAction.Request)
}

final class CourseListInteractor: CourseListInteractorProtocol {
    // We should be able to set uid cause we want to manage
    // which course list module called module output methods
    var moduleIdentifier: UniqueIdentifierType?

    weak var moduleOutput: CourseListOutputProtocol?

    private let presenter: CourseListPresenterProtocol
    private let provider: CourseListProviderProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let courseSubscriber: CourseSubscriberProtocol
    private let userAccountService: UserAccountServiceProtocol
    private let personalDeadlinesService: PersonalDeadlinesServiceProtocol
    private let wishlistService: WishlistServiceProtocol
    private let courseListDataBackUpdateService: CourseListDataBackUpdateServiceProtocol
    private let analytics: Analytics
    private let courseViewSource: AnalyticsEvent.CourseViewSource

    private let remoteConfig: RemoteConfig

    private var isOnline = false
    private var didLoadFromCache = false
    private var paginationState = PaginationState(page: 1, hasNext: true)
    private var currentCourses: [(UniqueIdentifierType, Course)] = []

    private var currentFilters: [CourseListFilter.Filter] = []
    private var currentFilterQuery: CourseListFilterQuery {
        CourseListFilterQuery(courseListFilters: self.currentFilters)
    }

    private var currentWishlistCoursesIDs = Set<Course.IdType>()

    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseListInteractor.CoursesFetch"
    )

    init(
        presenter: CourseListPresenterProtocol,
        provider: CourseListProviderProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        courseSubscriber: CourseSubscriberProtocol,
        userAccountService: UserAccountServiceProtocol,
        personalDeadlinesService: PersonalDeadlinesServiceProtocol,
        wishlistService: WishlistServiceProtocol,
        courseListDataBackUpdateService: CourseListDataBackUpdateServiceProtocol,
        analytics: Analytics,
        courseViewSource: AnalyticsEvent.CourseViewSource,
        remoteConfig: RemoteConfig
    ) {
        self.presenter = presenter
        self.provider = provider
        self.adaptiveStorageManager = adaptiveStorageManager
        self.courseSubscriber = courseSubscriber
        self.userAccountService = userAccountService
        self.personalDeadlinesService = personalDeadlinesService
        self.wishlistService = wishlistService
        self.analytics = analytics
        self.courseViewSource = courseViewSource
        self.remoteConfig = remoteConfig

        self.courseListDataBackUpdateService = courseListDataBackUpdateService
        self.courseListDataBackUpdateService.delegate = self
    }

    // MARK: - Public methods

    func doCoursesFetch(request: CourseList.CoursesLoad.Request) {
        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            // Check for state and
            // - isOnline && didLoadFromCache: we loaded cached courses (and not only cached courses), load from remote
            // - !isOnline && didLoadFromCache: we loaded cached courses, but can't load from network (it's just refresh from cache)
            // - isOnline && !didLoadFromCache: we should load cached courses and then load from network (recursive execute fetchCourses)
            // - !isOnline && !didLoadFromCache: we should load cached courses, but can't load from network (first fetch after init)
            firstly {
                strongSelf.didLoadFromCache
                    ? strongSelf.provider.fetchRemote(page: 1, filterQuery: strongSelf.currentFilterQuery)
                    : strongSelf.provider.fetchCached()
            }.done { courses, meta in
                strongSelf.paginationState = PaginationState(
                    page: meta.page,
                    hasNext: meta.hasNext
                )

                strongSelf.currentCourses = courses.map { (strongSelf.getUniqueIdentifierForCourse($0), $0) }
                strongSelf.currentWishlistCoursesIDs = Set(strongSelf.wishlistService.getWishlist())

                // Cache new courses fetched from remote.
                if strongSelf.didLoadFromCache && strongSelf.currentFilters.isEmpty {
                    strongSelf.provider.cache(courses: courses)
                }

                // Fetch personal deadlines
                if let userID = strongSelf.userAccountService.currentUser?.id, strongSelf.isOnline {
                    strongSelf.personalDeadlinesService.syncDeadlines(for: courses, userID: userID).cauterize()
                }

                if strongSelf.currentCourses.isEmpty {
                    // Offline mode: present empty state only if get empty courses from network
                    if strongSelf.isOnline && strongSelf.didLoadFromCache {
                        DispatchQueue.main.async {
                            strongSelf.moduleOutput?.presentEmptyState(sourceModule: strongSelf)
                        }
                    }
                } else {
                    let courses = CourseList.AvailableCourses(
                        fetchedCourses: CourseList.ListData(
                            courses: strongSelf.currentCourses,
                            hasNextPage: meta.hasNext
                        ),
                        availableAdaptiveCourses: strongSelf.getAvailableAdaptiveCourses(from: courses),
                        wishlistCoursesIDs: strongSelf.currentWishlistCoursesIDs
                    )

                    let response = CourseList.CoursesLoad.Response(
                        isAuthorized: strongSelf.userAccountService.isAuthorized,
                        isCoursePricesEnabled: strongSelf.remoteConfig.isCoursePricesEnabled,
                        result: courses,
                        viewSource: strongSelf.courseViewSource
                    )

                    DispatchQueue.main.async {
                        strongSelf.presenter.presentCourses(response: response)
                        strongSelf.moduleOutput?.presentLoadedState(sourceModule: strongSelf)
                    }
                }

                // Fetch & present similar course lists
                strongSelf.refreshSimilarCourseLists()

                // Retry if successfully
                let shouldRetryAfterFetching = strongSelf.isOnline && !strongSelf.didLoadFromCache
                if shouldRetryAfterFetching {
                    // End of recursion cause shouldRetryAfterFetching will be false on next call
                    strongSelf.didLoadFromCache = true
                    strongSelf.doCoursesFetch(request: request)
                }
            }.ensure {
                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                if case CourseListProvider.Error.networkFetchFailed = error,
                   strongSelf.didLoadFromCache,
                   !strongSelf.currentCourses.isEmpty {
                    // Offline mode: we already presented cached courses, but network request failed
                    // so let's ignore it and show only cached
                } else {
                    DispatchQueue.main.async {
                        strongSelf.moduleOutput?.presentError(sourceModule: strongSelf)
                    }
                }
            }
        }
    }

    func doNextCoursesFetch(request: CourseList.NextCoursesLoad.Request) {
        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            strongSelf.loadNextCourses().done { response in
                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextCourses(response: response)
                }
            }.ensure {
                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                let response = CourseList.NextCoursesLoad.Response(
                    isAuthorized: strongSelf.userAccountService.isAuthorized,
                    isCoursePricesEnabled: strongSelf.remoteConfig.isCoursePricesEnabled,
                    result: .failure(error),
                    viewSource: strongSelf.courseViewSource
                )

                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextCourses(response: response)
                }
            }
        }
    }

    func doPrimaryAction(request: CourseList.PrimaryCourseAction.Request) {
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        guard let targetIndex = self.currentCourses.firstIndex(where: { $0.0 == request.viewModelUniqueIdentifier }),
              let targetCourse = self.currentCourses[safe: targetIndex]?.1 else {
            fatalError("Invalid module state")
        }

        if !self.userAccountService.isAuthorized {
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            self.moduleOutput?.presentAuthorization()
            return
        }

        if targetCourse.enrolled {
            // Enrolled course -> open last step
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            self.moduleOutput?.presentLastStep(
                course: targetCourse,
                isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                    courseId: targetCourse.id
                ),
                source: .courseWidget,
                viewSource: self.courseViewSource
            )
        } else {
            // Paid course -> open web view
            if targetCourse.isPaid {
                //self.analytics.send(.courseBuyPressed(source: .courseWidget, id: targetCourse.id))
                //self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
                //self.moduleOutput?.presentPaidCourseInfo(course: targetCourse)
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
                self.moduleOutput?.presentCourseInfo(course: targetCourse, viewSource: self.courseViewSource)
                return
            }

            // Unenrolled course -> join, open last step
            self.courseSubscriber.join(course: targetCourse, source: .widget).done { course in
                self.currentCourses[targetIndex].1 = course

                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
                self.moduleOutput?.presentLastStep(
                    course: targetCourse,
                    isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                        courseId: targetCourse.id
                    ),
                    source: .courseWidget,
                    viewSource: self.courseViewSource
                )
            }.catch { _ in
                // FIXME: use dismiss with error
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            }
        }
    }

    func doMainAction(request: CourseList.MainCourseAction.Request) {
        guard let targetIndex = self.currentCourses.firstIndex(where: { $0.0 == request.viewModelUniqueIdentifier }),
              let targetCourse = self.currentCourses[safe: targetIndex]?.1 else {
            fatalError("Invalid module state")
        }

        if targetCourse.enrolled {
            // Enrolled course
            // - adaptive -> info
            // - normal -> syllabus
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            if self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: targetCourse.id) {
                self.moduleOutput?.presentCourseInfo(course: targetCourse, viewSource: self.courseViewSource)
            } else {
                self.moduleOutput?.presentCourseSyllabus(course: targetCourse, viewSource: self.courseViewSource)
            }
        } else {
            // Unenrolled course
            // - adaptive -> info
            // - normal -> info
            self.moduleOutput?.presentCourseInfo(course: targetCourse, viewSource: self.courseViewSource)
        }
    }

    // MARK: - Private API

    private func loadNextCourses() -> Promise<CourseList.NextCoursesLoad.Response> {
        Promise { seal in
            // If we are
            // - in offline mode
            // - have no more courses
            // then ignore request and pass empty list to presenter
            if !self.isOnline || !self.paginationState.hasNext {
                self.currentWishlistCoursesIDs = Set(self.wishlistService.getWishlist())
                let result = CourseList.AvailableCourses(
                    fetchedCourses: CourseList.ListData(courses: [], hasNextPage: false),
                    availableAdaptiveCourses: Set<Course>(),
                    wishlistCoursesIDs: self.currentWishlistCoursesIDs
                )
                let response = CourseList.NextCoursesLoad.Response(
                    isAuthorized: self.userAccountService.isAuthorized,
                    isCoursePricesEnabled: self.remoteConfig.isCoursePricesEnabled,
                    result: .success(result),
                    viewSource: self.courseViewSource
                )

                seal.fulfill(response)
                return
            }

            let nextPageNumber = self.paginationState.page + 1
            self.provider.fetchRemote(
                page: nextPageNumber,
                filterQuery: self.currentFilterQuery
            ).done { courses, meta in
                self.paginationState = PaginationState(
                    page: meta.page,
                    hasNext: meta.hasNext
                )

                let appendedCourses = courses.map { (self.getUniqueIdentifierForCourse($0), $0) }
                self.currentCourses.append(contentsOf: appendedCourses)
                self.currentWishlistCoursesIDs = Set(self.wishlistService.getWishlist())

                let courses = CourseList.AvailableCourses(
                    fetchedCourses: CourseList.ListData(
                        courses: appendedCourses,
                        hasNextPage: meta.hasNext
                    ),
                    availableAdaptiveCourses: self.getAvailableAdaptiveCourses(from: courses),
                    wishlistCoursesIDs: self.currentWishlistCoursesIDs
                )
                let response = CourseList.NextCoursesLoad.Response(
                    isAuthorized: self.userAccountService.isAuthorized,
                    isCoursePricesEnabled: self.remoteConfig.isCoursePricesEnabled,
                    result: .success(courses),
                    viewSource: self.courseViewSource
                )

                self.cacheCurrentCourses()

                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func getAvailableAdaptiveCourses(from courses: [Course]) -> Set<Course> {
        let availableInAdaptiveMode = courses
            .filter { self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: $0.id) }
        return Set<Course>(availableInAdaptiveMode)
    }

    private func getUniqueIdentifierForCourse(_ course: Course) -> UniqueIdentifierType { "\(course.id)" }

    private func updateCourseInCurrentCourses(_ course: Course) {
        guard let targetIndex = self.currentCourses.firstIndex(where: { $0.1 == course }) else {
            return
        }
        self.currentCourses[targetIndex] = (self.getUniqueIdentifierForCourse(course), course)
    }

    private func deleteCourseInCurrentCourses(_ course: Course) {
        self.currentCourses.removeAll { $0.0 == self.getUniqueIdentifierForCourse(course) }
    }

    private func insertCourseInCurrentCourses(_ course: Course) {
        let newElement = (self.getUniqueIdentifierForCourse(course), course)

        if let targetIndex = self.currentCourses.firstIndex(where: { $0.1 == course }) {
            self.currentCourses[targetIndex] = newElement
        } else {
            self.currentCourses.insert(newElement, at: 0)
        }
    }

    private func cacheCurrentCourses() {
        if self.currentFilters.isEmpty {
            self.provider.cache(courses: self.currentCourses.map { $0.1 })
        }
    }

    /// Just present current data again
    private func refreshCourseList() {
        let courses = CourseList.AvailableCourses(
            fetchedCourses: CourseList.ListData(
                courses: self.currentCourses,
                hasNextPage: self.paginationState.hasNext
            ),
            availableAdaptiveCourses: self.getAvailableAdaptiveCourses(
                from: self.currentCourses.map { $0.1 }
            ),
            wishlistCoursesIDs: self.currentWishlistCoursesIDs
        )
        let response = CourseList.CoursesLoad.Response(
            isAuthorized: self.userAccountService.isAuthorized,
            isCoursePricesEnabled: self.remoteConfig.isCoursePricesEnabled,
            result: courses,
            viewSource: self.courseViewSource
        )
        self.presenter.presentCourses(response: response)
    }

    private func refreshSimilarCourseLists() {
        self.provider.fetchCachedCourseList().done { courseListOrNil in
            guard let courseList = courseListOrNil else {
                return
            }

            if !courseList.similarAuthorsArray.isEmpty {
                self.moduleOutput?.presentSimilarAuthors(courseList.similarAuthorsArray)
            }

            if !courseList.similarCourseListsArray.isEmpty {
                self.moduleOutput?.presentSimilarCourseLists(courseList.similarCourseListsArray)
            }
        }
    }

    // MARK: - Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseListInteractor: CourseListInputProtocol {
    func setOnlineStatus() {
        guard !self.isOnline else {
            return
        }

        self.isOnline = true

        // Cached courses already loaded, now refresh with new state
        if self.didLoadFromCache {
            let fakeRequest = CourseList.CoursesLoad.Request()
            self.doCoursesFetch(request: fakeRequest)
        }
    }

    func applyFilters(_ filters: [CourseListFilter.Filter]) {
        if self.currentFilters == filters {
            return
        }

        self.currentFilters = filters
        self.doCoursesFetch(request: .init())
    }

    func loadAllCourses() {
        func load() -> Guarantee<Bool> {
            Guarantee { seal in
                self.loadNextCourses().done { response in
                    if case .success = response.result, self.paginationState.hasNext {
                        seal(true)
                    } else {
                        seal(false)
                    }
                }.catch { _ in
                    seal(false)
                }
            }
        }

        func collect() -> Guarantee<Void> {
            load().then { hasNext -> Guarantee<Void> in
                if hasNext {
                    return collect()
                } else {
                    return .value(())
                }
            }
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            collect().done {
                strongSelf.fetchSemaphore.signal()

                DispatchQueue.main.async {
                    strongSelf.refreshCourseList()
                }
            }
        }
    }
}

extension CourseListInteractor: CourseListDataBackUpdateServiceDelegate {
    func courseListDataBackUpdateService(
        _ service: CourseListDataBackUpdateServiceProtocol,
        didUpdateCourse course: Course
    ) {
        self.updateCourseInCurrentCourses(course)
        self.refreshCourseList()
    }

    func courseListDataBackUpdateService(
        _ service: CourseListDataBackUpdateServiceProtocol,
        didDeleteCourse course: Course
    ) {
        self.deleteCourseInCurrentCourses(course)
        self.cacheCurrentCourses()
        self.refreshCourseList()
    }

    func courseListDataBackUpdateService(
        _ service: CourseListDataBackUpdateServiceProtocol,
        didInsertCourse course: Course
    ) {
        self.insertCourseInCurrentCourses(course)
        self.cacheCurrentCourses()
        self.refreshCourseList()
    }

    func courseListDataBackUpdateService(
        _ service: CourseListDataBackUpdateServiceProtocol,
        didUpdateUserCourse userCourse: UserCourse
    ) {
        if let course = self.currentCourses.first(where: { $0.1.id == userCourse.courseID })?.1 {
            self.updateCourseInCurrentCourses(course)
            self.refreshCourseList()
        }
    }

    func courseListDataBackUpdateServiceDidUpdateCourseList(_ service: CourseListDataBackUpdateServiceProtocol) {
        self.doCoursesFetch(request: .init())
    }

    func courseListDataBackUpdateService(
        _ service: CourseListDataBackUpdateServiceProtocol,
        didUpdateWishlist wishlistCoursesIDs: Set<Course.IdType>
    ) {
        let currentCoursesIDs = Set(self.currentCourses.map(\.1.id))

        let shoulsRefreshCourseList = !currentCoursesIDs.isDisjoint(with: wishlistCoursesIDs)
            || (!self.currentWishlistCoursesIDs.isDisjoint(with: wishlistCoursesIDs)
                    && !currentCoursesIDs.isDisjoint(with: self.currentWishlistCoursesIDs))

        self.currentWishlistCoursesIDs = wishlistCoursesIDs

        if shoulsRefreshCourseList {
            refreshCourseList()
        }
    }
}
