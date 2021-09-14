import Foundation
import PromiseKit

protocol CourseInfoTabNewsInteractorProtocol {
    func doCourseNewsFetch(request: CourseInfoTabNews.NewsLoad.Request)
}

final class CourseInfoTabNewsInteractor: CourseInfoTabNewsInteractorProtocol {
    private let presenter: CourseInfoTabNewsPresenterProtocol
    private let provider: CourseInfoTabNewsProviderProtocol
    private let analytics: Analytics

    private var currentCourse: Course?
    private var isOnline = false
    private var didLoadFromCache = false
    private var didPresentCourseNews = false
    private var paginationState = PaginationState(page: 1, hasNext: true)
    private var shouldOpenedAnalyticsEventSend = false

    // Semaphore to prevent concurrent fetching
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseInfoTabNewsInteractor.NewsFetch"
    )

    init(
        presenter: CourseInfoTabNewsPresenterProtocol,
        provider: CourseInfoTabNewsProviderProtocol,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
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
                assert(Thread.current.isMainThread)

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

    // MARK: Private API

    private func fetchNewsInAppropriateMode(
        course: Course,
        isOnline: Bool
    ) -> Promise<CourseInfoTabNews.NewsLoad.Data> {
        Promise { seal in
            firstly {
                isOnline && self.didLoadFromCache
                    ? self.provider.fetchRemote(courseID: course.id, page: 1)
                    : self.provider.fetchCached(courseID: course.id)
            }.done { announcements, meta in
                let sortedAnnouncements = announcements
                let responseData = CourseInfoTabNews.NewsLoad.Data(
                    course: course,
                    announcements: sortedAnnouncements,
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

        self.doCourseNewsFetch(request: .init())

        if self.shouldOpenedAnalyticsEventSend {
            self.analytics.send(.courseNewsScreenOpened(id: course.id, title: course.title))
            self.shouldOpenedAnalyticsEventSend = false
        }
    }
}
