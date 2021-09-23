import Foundation
import PromiseKit

protocol CourseInfoTabNewsInteractorProtocol {
    func doCourseNewsFetch(request: CourseInfoTabNews.NewsLoad.Request)
    func doNextCourseNewsFetch(request: CourseInfoTabNews.NextNewsLoad.Request)
}

final class CourseInfoTabNewsInteractor: CourseInfoTabNewsInteractorProtocol {
    private static let fetchDebounceInterval: TimeInterval = 1

    private let presenter: CourseInfoTabNewsPresenterProtocol
    private let provider: CourseInfoTabNewsProviderProtocol

    private let userAccountService: UserAccountServiceProtocol
    private let analytics: Analytics

    private var currentCourse: Course?
    private var isOnline = false
    private var didLoadFromCache = false
    private var didPresentCourseNews = false
    private var paginationState = PaginationState(page: 1, hasNext: true)
    private var shouldOpenedAnalyticsEventSend = false

    private let fetchDebouncer = Debouncer(delay: CourseInfoTabNewsInteractor.fetchDebounceInterval)
    // Semaphore to prevent concurrent fetching
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseInfoTabNewsInteractor.NewsFetch"
    )

    init(
        presenter: CourseInfoTabNewsPresenterProtocol,
        provider: CourseInfoTabNewsProviderProtocol,
        userAccountService: UserAccountServiceProtocol,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
        self.userAccountService = userAccountService
        self.analytics = analytics
    }

    func doCourseNewsFetch(request: CourseInfoTabNews.NewsLoad.Request) {
        guard let course = self.currentCourse else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let isOnline = strongSelf.isOnline
            print("CourseInfoTabNewsInteractor :: start fetching news, isOnline = \(isOnline)")

            strongSelf.fetchNewsInAppropriateMode(course: course, isOnline: isOnline).done { data in
                let isCacheEmpty = !strongSelf.didLoadFromCache && data.announcements.isEmpty

                strongSelf.paginationState = PaginationState(page: 1, hasNext: data.hasNextPage)
                DispatchQueue.main.async {
                    print("CourseInfoTabNewsInteractor :: finish fetching news, isOnline = \(isOnline)")

                    if isCacheEmpty {
                        // Wait for remote fetch result.
                    } else {
                        strongSelf.didPresentCourseNews = true
                        strongSelf.presenter.presentCourseNews(response: .init(result: .success(data)))
                    }
                }

                if !strongSelf.didLoadFromCache {
                    strongSelf.didLoadFromCache = true
                    strongSelf.doCourseNewsFetch(request: .init())
                }
            }.catch { error in
                guard let strongSelf = self else {
                    return
                }

                if case Error.remoteFetchFailed = error,
                   strongSelf.didLoadFromCache && !strongSelf.didPresentCourseNews {
                    strongSelf.presenter.presentCourseNews(response: .init(result: .failure(error)))
                }
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doNextCourseNewsFetch(request: CourseInfoTabNews.NextNewsLoad.Request) {
        guard self.isOnline, self.paginationState.hasNext, let course = self.currentCourse else {
            return
        }

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let nextPageIndex = strongSelf.paginationState.page + 1
            print("CourseInfoTabNewsInteractor :: load next page, page = \(nextPageIndex)")

            strongSelf.provider.fetchRemote(courseID: course.id, page: nextPageIndex).done { announcements, meta in
                strongSelf.paginationState = PaginationState(page: nextPageIndex, hasNext: meta.hasNext)

                let responseData = CourseInfoTabNews.NewsResponseData(
                    course: course,
                    currentUser: strongSelf.userAccountService.currentUser,
                    announcements: strongSelf.sortedAnnouncements(announcements),
                    hasNextPage: meta.hasNext
                )

                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextCourseNews(response: .init(result: .success(responseData)))
                }
            }.catch { error in
                print("CourseInfoTabNewsInteractor :: failed load next page with error = \(error)")
                strongSelf.presenter.presentNextCourseNews(response: .init(result: .failure(error)))
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    // MARK: Private API

    private func fetchNewsInAppropriateMode(
        course: Course,
        isOnline: Bool
    ) -> Promise<CourseInfoTabNews.NewsResponseData> {
        Promise { seal in
            firstly {
                isOnline && self.didLoadFromCache
                    ? self.provider.fetchRemote(ids: course.announcementsArray, courseID: course.id)
                    : self.provider.fetchCached(ids: course.announcementsArray, courseID: course.id)
            }.done { announcements, meta in
                let responseData = CourseInfoTabNews.NewsResponseData(
                    course: course,
                    currentUser: self.userAccountService.currentUser,
                    announcements: self.sortedAnnouncements(announcements),
                    hasNextPage: meta.hasNext
                )
                seal.fulfill(responseData)
            }.catch { error in
                if let providerError = error as? CourseInfoTabNewsProvider.Error {
                    switch providerError {
                    case .persistenceFetchFailed:
                        seal.reject(Error.cacheFetchFailed)
                    case .networkFetchFailed:
                        seal.reject(Error.remoteFetchFailed)
                    }
                } else {
                    seal.reject(Error.fetchFailed)
                }
            }
        }
    }

    private func sortedAnnouncements(_ announcements: [AnnouncementPlainObject]) -> [AnnouncementPlainObject] {
        guard let course = self.currentCourse else {
            return announcements
        }

        if course.canCreateAnnouncements {
            return announcements.sorted { lhs, rhs in
                let lhsCreateDate = lhs.createDate ?? Date()
                let rhsCreateDate = rhs.createDate ?? Date()

                if lhsCreateDate == rhsCreateDate {
                    let lhsStatusRank = lhs.status?.rank ?? 0
                    let rhsStatusRank = rhs.status?.rank ?? 0

                    return lhsStatusRank < rhsStatusRank
                }

                return lhsCreateDate > rhsCreateDate
            }
        } else {
            return announcements.sorted { lhs, rhs in
                (lhs.sentDate ?? Date()) > (rhs.sentDate ?? Date())
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case cacheFetchFailed
        case remoteFetchFailed
    }
}

// MARK: - CourseInfoTabNewsInteractor: CourseInfoTabNewsInputProtocol -

extension CourseInfoTabNewsInteractor: CourseInfoTabNewsInputProtocol {
    func handleControllerAppearance() {
        if let course = self.currentCourse {
            self.analytics.send(.courseNewsScreenOpened(id: course.id, title: course.title))
            self.shouldOpenedAnalyticsEventSend = false
        } else {
            self.shouldOpenedAnalyticsEventSend = true
        }
    }

    func update(with course: Course, viewSource: AnalyticsEvent.CourseViewSource, isOnline: Bool) {
        self.currentCourse = course
        self.isOnline = isOnline

        self.fetchDebouncer.action = { [weak self] in
            self?.doCourseNewsFetch(request: .init())
        }

        if self.shouldOpenedAnalyticsEventSend {
            self.analytics.send(.courseNewsScreenOpened(id: course.id, title: course.title))
            self.shouldOpenedAnalyticsEventSend = false
        }
    }
}
