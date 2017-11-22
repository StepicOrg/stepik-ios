//
//  CourseListPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

protocol CourseListView: class {
    func display(courses: [CourseViewData])
    func add(addedCourses: [CourseViewData], courses: [CourseViewData])
    func update(updatedCourses: [CourseViewData], courses: [CourseViewData])
    func update(deletingIds: [Int], insertingIds: [Int], courses: [CourseViewData])

    func setState(state: CourseListState)

    func setPaginationStatus(status: PaginationStatus)

    func present(controller: UIViewController)
    func show(controller: UIViewController)

    func startProgressHUD()
    func finishProgressHUD(success: Bool, message: String)

    var colorMode: CourseListColorMode! { get set }

    func getNavigationController() -> UINavigationController?
    func getController() -> UIViewController?
}

protocol LastStepWidgetDataSource: class {
    func didLoadWithProgresses(courses: [Course])
}

protocol CourseListCountDelegate: class {
    func updateCourseCount(to: Int, forListID: String)
}

class CourseListPresenter {
    private var coursesAPI: CoursesAPI
    private var progressesAPI: ProgressesAPI
    private var reviewSummariesAPI: CourseReviewSummariesAPI
    private var searchResultsAPI: SearchResultsAPI
    private var subscriptionManager: CourseSubscriptionManager

    private var colorMode: CourseListColorMode
    private var onlyLocal: Bool

    private var ID: String

    private weak var view: CourseListView?
    private var limit: Int?
    var listType: CourseListType

    private var currentPage: Int = 1
    private var hasNextPage: Bool = false

    private var lastUser: User?
    private var subscriber = CourseSubscriber()
    private var lastLanguage: ContentLanguage

    weak var lastStepDataSource: LastStepWidgetDataSource?
    weak var couseListCountDelegate: CourseListCountDelegate?

    private var didRefreshOnce: Bool = false

    private var state: CourseListState = .empty {
        didSet {
            if state != oldValue {
                view?.setState(state: state)
            }
        }
    }

    private var shouldLoadNextPage: Bool {
        if let limit = limit {
            return hasNextPage && courses.count < limit
        } else {
            return hasNextPage
        }
    }

    private var courses: [Course] = [] {
        didSet {
            listType.cachedListCourseIds = courses.map({ $0.id })
            print("\(ID): cached courses with ids: \(listType.cachedListCourseIds)")
            if let limit = limit {
                displayingCourses = [Course](courses.prefix(limit))
            } else {
                displayingCourses = courses
            }
            self.couseListCountDelegate?.updateCourseCount(to: courses.count, forListID: ID)
        }
    }

    private var displayingCourses: [Course] = []
    private func getDisplaying(from newCourses: [Course]) -> [Course] {
        var result: [Course] = []
        for course in displayingCourses {
            if newCourses.index(of: course) != nil {
                result += [course]
            }
        }
        return result
    }

    init(view: CourseListView, ID: String, limit: Int?, listType: CourseListType, colorMode: CourseListColorMode, onlyLocal: Bool, subscriptionManager: CourseSubscriptionManager, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI, reviewSummariesAPI: CourseReviewSummariesAPI, searchResultsAPI: SearchResultsAPI, subscriber: CourseSubscriber) {
        self.view = view
        self.ID = ID
        self.coursesAPI = coursesAPI
        self.progressesAPI = progressesAPI
        self.reviewSummariesAPI = reviewSummariesAPI
        self.limit = limit
        self.listType = listType
        self.colorMode = colorMode
        self.subscriber = subscriber
        self.lastUser = AuthInfo.shared.user
        self.lastLanguage = ContentLanguage.sharedContentLanguage
        self.onlyLocal = onlyLocal
        self.searchResultsAPI = searchResultsAPI
        self.subscriptionManager = subscriptionManager
        subscriptionManager.handleUpdatesBlock = {
            [weak self] in
            self?.handleCourseSubscriptionUpdates()
        }
        subscriptionManager.startObservingOtherSubscriptionManagers()
        view.colorMode = colorMode
    }

    private var reachabilityManager: Alamofire.NetworkReachabilityManager?
    private func setupNetworkReachabilityListener() {
        guard reachabilityManager == nil else {
            return
        }
        reachabilityManager = Alamofire.NetworkReachabilityManager(host: StepicApplicationsInfo.stepicURL)
        reachabilityManager?.listener = {
            [weak self]
            status in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.didRefreshOnce {
                switch status {
                case .reachable(_):
                    strongSelf.refresh()
                default:
                    break
                }
            }
        }
        reachabilityManager?.startListening()
    }

    func getData(from courses: [Course]) -> [CourseViewData] {
        return courses.map {
            course in
            CourseViewData(course: course, action: {
                [weak self] in
                self?.actionButtonPressed(course: course)
            }, secondaryAction: {
                [weak self] in
                self?.secondaryActionButtonPressed(course: course)
            })
        }
    }

    private func subscribe(to course: Course) {
        self.view?.startProgressHUD()
        checkToken().then {
            [weak self]
            () -> Promise<Course> in
            guard let strongSelf = self else {
                throw CourseSubscriber.CourseSubscriptionError.error(status: "")
            }
            return strongSelf.subscriber.join(course: course)
        }.then {
            [weak self]
            course -> Void in
            self?.view?.finishProgressHUD(success: true, message: "")
            if let controller = self?.getSectionsController(for: course) {
                self?.view?.show(controller: controller)
            }
        }.catch {
            [weak self]
            error in
            guard let error = error as? CourseSubscriber.CourseSubscriptionError else {
                self?.view?.finishProgressHUD(success: false, message: "")
                return
            }
            switch error {
            case let .error(status: status):
                self?.view?.finishProgressHUD(success: false, message: status)
            case .badResponseFormat:
                self?.view?.finishProgressHUD(success: false, message: "")
            }
        }
    }

    private func actionButtonPressed(course: Course) {
        if course.enrolled {
            if let navigation = view?.getNavigationController() {
                LastStepRouter.continueLearning(for: course, using: navigation)
            }
        } else {
            let joinBlock: (() -> Void) = {
                [weak self] in
                self?.subscribe(to: course)
            }
            if !AuthInfo.shared.isAuthorized {
                guard let vc = self.view?.getController() else {
                    return
                }
                AuthInfo.shared.token = nil
                RoutingManager.auth.routeFrom(controller: vc, success: joinBlock, cancel: nil)
            } else {
                joinBlock()
            }
        }
    }

    private func secondaryActionButtonPressed(course: Course) {
        if course.enrolled {
            if let controller = getSectionsController(for: course) {
                self.view?.show(controller: controller)
            }
        } else {
            if let controller = getCoursePreviewController(for: course) {
                self.view?.show(controller: controller)
            }
        }
    }

    func refresh() {
        if courses.isEmpty {
            displayCached(ids: listType.cachedListCourseIds)
        }
        if onlyLocal {
            state = courses.isEmpty ? .empty : .displaying
            return
        }
        state = courses.isEmpty ? .emptyRefreshing : .displayingWithRefreshing
        checkToken().then {
            [weak self] in
            self?.refreshCourses()
        }.catch {
            [weak self]
            error in
            guard let strongSelf = self else {
                return
            }
            strongSelf.state = strongSelf.courses.isEmpty ? .emptyError : .displayingWithError
            guard let vc = self?.view?.getController(), (error as? PerformRequestError) == PerformRequestError.noAccessToRefreshToken else {
                return
            }
            AuthInfo.shared.token = nil
            RoutingManager.auth.routeFrom(controller: vc, success: nil, cancel: nil)
        }
    }

    func loadNextPage() {
        guard self.hasNextPage else {
            return
        }
        self.view?.setPaginationStatus(status: .loading)
        coursesAPI.cancelAllTasks()
        listType.request(page: currentPage + 1, language: ContentLanguage.sharedContentLanguage, withAPI: coursesAPI, progressesAPI: progressesAPI, searchResultsAPI: searchResultsAPI)?.then {
            [weak self]
            (courses, meta) -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.courses += courses
            strongSelf.view?.add(addedCourses: strongSelf.getData(from: strongSelf.getDisplaying(from: courses)), courses: strongSelf.getData(from: strongSelf.displayingCourses))
            strongSelf.updateReviewSummaries(for: courses)
            strongSelf.updateProgresses(for: courses)
            strongSelf.currentPage = meta.page
            strongSelf.hasNextPage = meta.hasNext
            strongSelf.view?.setPaginationStatus(status: strongSelf.shouldLoadNextPage ? .loading : .none)
        }.catch {
            [weak self]
            _ in
            print("error while loading next page")
            self?.view?.setPaginationStatus(status: .error)
        }
    }

    private var shouldRefreshLanguage: Bool {
        switch listType {
        case .enrolled:
            return false
        default:
            return lastLanguage != ContentLanguage.sharedContentLanguage
        }
    }

    func willAppear() {
        if lastUser != AuthInfo.shared.user || shouldRefreshLanguage {
            courses = []
            self.view?.display(courses: [])
            lastUser = AuthInfo.shared.user
            lastLanguage = ContentLanguage.sharedContentLanguage
            refresh()
            return
        } else {
            handleCourseSubscriptionUpdates()
            switch listType {
            case .enrolled:
                lastStepDataSource?.didLoadWithProgresses(courses: courses)
            default:
                break
            }
        }
    }

    func handleCourseSubscriptionUpdates() {
        guard subscriptionManager.hasUpdates else {
            return
        }

        switch state {
        case .emptyRefreshing, .displayingWithRefreshing:
            return
        default:
            break
        }

        switch listType {
        case .enrolled:
            let oldDisplayedCourses = getDisplaying(from: courses)

            let deletedCourses = subscriptionManager.deletedCourses
            var deletedIds: [Int] = []
            var addedIds: [Int] = []
            for deletedCourse in deletedCourses {
                if let index = courses.index(where: { deletedCourse.id == $0.id }) {
                    courses.remove(at: index)
                }
            }

            let addedCourses = subscriptionManager.addedCourses
            courses = addedCourses + courses

            subscriptionManager.clean()

            let newDisplayedCourses = getDisplaying(from: courses)
            let deletedDisplayedCourses = oldDisplayedCourses.filter({
                !newDisplayedCourses.contains($0)
            })
            let addedDisplayedCourses = newDisplayedCourses.filter({
                !oldDisplayedCourses.contains($0)
            })
            oldDisplayedCourses.enumerated().forEach({
                index, oldDisplayedCourse in
                if deletedDisplayedCourses.contains(oldDisplayedCourse) {
                    deletedIds += [index]
                }
            })
            newDisplayedCourses.enumerated().forEach({
                index, newDisplayedCourse in
                if addedDisplayedCourses.contains(newDisplayedCourse) {
                    addedIds += [index]
                }
            })
            if oldDisplayedCourses.isEmpty && !newDisplayedCourses.isEmpty {
                self.state = .displaying
            }
            if !oldDisplayedCourses.isEmpty && newDisplayedCourses.isEmpty {
                self.state = .empty
            }
            if oldDisplayedCourses.count - deletedIds.count + addedIds.count == newDisplayedCourses.count {
                view?.update(deletingIds: deletedIds, insertingIds: addedIds, courses: getData(from: newDisplayedCourses))
            } else {
                view?.display(courses: getData(from: newDisplayedCourses))
            }
        default:
            let updatedCourses = subscriptionManager.addedCourses + subscriptionManager.deletedCourses
            subscriptionManager.clean()
            self.view?.update(updatedCourses: getData(from: getDisplaying(from: updatedCourses)), courses: getData(from: getDisplaying(from: courses)))
            return
        }
    }

    private func displayCached(ids: [Int]) {
        let recoveredCourses = Course.getCourses(ids)
        courses = Sorter.sort(recoveredCourses, byIds: ids)
        self.view?.display(courses: getData(from: self.displayingCourses))
    }

    private func handleRefreshError(error: Error) {
        print("Error while refreshing collection")
        if let error = error as? RetrieveError {
            switch error {
            case .badStatus:
                guard !AuthInfo.shared.isAuthorized else {
                    break
                }
                if !self.courses.isEmpty {
                    self.view?.display(courses: [])
                }
                self.state = .emptyAnonymous
            default:
                break
            }
        }
        self.state = self.courses.isEmpty ? .emptyError : .displayingWithError
    }

    private func requestNonCollection(updateProgresses: Bool, completion: (() -> Void)? = nil) {
        listType.request(page: 1, language: ContentLanguage.sharedContentLanguage, withAPI: coursesAPI, progressesAPI: progressesAPI, searchResultsAPI: searchResultsAPI)?.then {
            [weak self]
            (courses, meta) -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.courses = courses
            strongSelf.state = courses.isEmpty ? .empty: .displaying
            strongSelf.view?.display(courses: strongSelf.getData(from: strongSelf.displayingCourses))
            strongSelf.updateReviewSummaries(for: courses)
            if updateProgresses {
                strongSelf.updateProgresses(for: courses)
            }
            strongSelf.currentPage = meta.page
            strongSelf.hasNextPage = meta.hasNext
            strongSelf.view?.setPaginationStatus(status: strongSelf.shouldLoadNextPage ? .loading : .none)
            strongSelf.didRefreshOnce = true
            completion?()
            }.catch {
                [weak self]
                _ in
                guard let strongSelf = self else {
                    return
                }
                print("Error while refreshing collection")
                if !strongSelf.didRefreshOnce {
                    strongSelf.setupNetworkReachabilityListener()
                }
                strongSelf.state = strongSelf.courses.isEmpty ? .emptyError : .displayingWithError
                completion?()
        }
    }

    private func refreshCourses() {
        coursesAPI.cancelAllTasks()
        switch listType {
        case let .collection(ids: ids):
            listType.request(coursesWithIds: ids, withAPI: coursesAPI)?.then {
                [weak self]
                courses -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.courses = Sorter.sort(courses, byIds: ids)
                strongSelf.state = courses.isEmpty ? .empty: .displaying
                strongSelf.view?.display(courses: strongSelf.getData(from: strongSelf.displayingCourses))
                strongSelf.updateReviewSummaries(for: courses)
                strongSelf.updateProgresses(for: courses)
                strongSelf.currentPage = 1
                strongSelf.hasNextPage = false
                strongSelf.view?.setPaginationStatus(status: strongSelf.shouldLoadNextPage ? .loading : .none)
                strongSelf.didRefreshOnce = true
            }.catch {
                [weak self]
                _ in
                guard let strongSelf = self else {
                    return
                }
                print("Error while refreshing collection")
                if !strongSelf.didRefreshOnce {
                    strongSelf.setupNetworkReachabilityListener()
                }
                strongSelf.state = strongSelf.courses.isEmpty ? .emptyError : .displayingWithError
            }
        case .enrolled:
            if !AuthInfo.shared.isAuthorized {
                self.courses = []
                self.view?.display(courses: [])
                self.lastStepDataSource?.didLoadWithProgresses(courses: courses)
                self.state = .emptyAnonymous
                return
            }
            requestNonCollection(updateProgresses: false, completion: {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.lastStepDataSource?.didLoadWithProgresses(courses: strongSelf.courses)
            })
        default:
            state = courses.isEmpty ? .emptyRefreshing : .displayingWithRefreshing
            requestNonCollection(updateProgresses: true)
        }
    }

    private func getSectionsController(for course: Course, sourceView: UIView? = nil) -> UIViewController? {
        guard let courseVC = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as? SectionsViewController else {
            return nil
        }
        AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.peeked)
        courseVC.course = course
        courseVC.parentShareBlock = {
            [weak self]
            shareVC in
            AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.shared)
            shareVC.popoverPresentationController?.sourceView = sourceView
            self?.view?.present(controller: shareVC)
        }
        courseVC.hidesBottomBarWhenPushed = true
        return courseVC
    }

    private func getCoursePreviewController(for course: Course, sourceView: UIView? = nil) -> UIViewController? {
        guard let courseVC = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as? CoursePreviewViewController else {
            return nil
        }
        AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.peeked)
        courseVC.course = course
        courseVC.parentShareBlock = {
            [weak self]
            shareVC in
            AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.shared)
            shareVC.popoverPresentationController?.sourceView = sourceView
            self?.view?.present(controller: shareVC)
        }
        courseVC.hidesBottomBarWhenPushed = true
        return courseVC
    }

    func getViewControllerFor3DTouchPreviewing(forCourseAtIndex index: Int, withSourceView sourceView: UIView) -> UIViewController? {
        let course = courses[index]
        return course.enrolled ? getSectionsController(for: course, sourceView: sourceView) : getCoursePreviewController(for: course, sourceView: sourceView)
    }

    // Progresses

    @discardableResult private func updateProgresses(for courses: [Course]) -> Promise<[Course]> {
        var progressIds: [String] = []
        var progresses: [Progress] = []
        for course in courses {
            if let progressId = course.progressId {
                progressIds += [progressId]
            }
            if let progress = course.progress {
                progresses += [progress]
            }
        }

        return Promise {
            fulfill, reject in
            progressesAPI.getObjectsByIds(ids: progressIds, updating: progresses).then {
                [weak self]
                newProgresses -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.matchProgresses(newProgresses: newProgresses, ids: progressIds, courses: courses)
                strongSelf.view?.update(updatedCourses: strongSelf.getData(from: strongSelf.getDisplaying(from: courses)), courses: strongSelf.getData(from: strongSelf.displayingCourses))
                fulfill(strongSelf.courses)
            }.catch {
                error in
                print("Error while loading progresses")
                reject(error)
            }
        }
    }

    private func matchProgresses(newProgresses: [Progress], ids progressIds: [String], courses: [Course]) {
        let progresses = Sorter.sort(newProgresses, byIds: progressIds)

        if progresses.count == 0 {
            CoreDataHelper.instance.save()
            return
        }

        var progressCnt = 0
        for i in 0 ..< courses.count {
            if courses[i].progressId == progresses[progressCnt].id {
                courses[i].progress = progresses[progressCnt]
                progressCnt += 1
            }
            if progressCnt == progresses.count {
                break
            }
        }
        CoreDataHelper.instance.save()
    }

    //Review summaries

    private func updateReviewSummaries(for courses: [Course]) {
        var reviewIds: [Int] = []
        var reviews: [CourseReviewSummary] = []
        for course in courses {
            if let reviewId = course.reviewSummaryId {
                reviewIds += [reviewId]
            }
            if let review = course.reviewSummary {
                reviews += [review]
            }
        }

        reviewSummariesAPI.getObjectsByIds(ids: reviewIds, updating: reviews).then {
            [weak self]
            newReviews -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.matchReviewSummaries(newReviewSummaries: newReviews, ids: reviewIds, courses: courses)
            strongSelf.view?.update(updatedCourses: strongSelf.getData(from: strongSelf.getDisplaying(from: courses)), courses: strongSelf.getData(from: strongSelf.courses) )
        }.catch {
            _ in
            print("error while loading review summaries")
        }
    }

    private func matchReviewSummaries(newReviewSummaries: [CourseReviewSummary], ids reviewIds: [Int], courses: [Course]) {
        let reviews = Sorter.sort(newReviewSummaries, byIds: reviewIds)
        if reviews.count == 0 {
            CoreDataHelper.instance.save()
            return
        }

        var reviewCnt = 0
        for i in 0 ..< courses.count {
            if courses[i].reviewSummaryId == reviews[reviewCnt].id {
                courses[i].reviewSummary = reviews[reviewCnt]
                reviewCnt += 1
            }
            if reviewCnt == reviews.count {
                break
            }
        }
        CoreDataHelper.instance.save()
    }
}

struct CourseViewData {
    var id: Int
    var title: String
    var isEnrolled: Bool
    var coverURLString: String
    var rating: Float?
    var learners: Int?
    var progress: Float?
    var action: (() -> Void)?
    var secondaryAction: (() -> Void)?
    init(course: Course, action: @escaping () -> Void, secondaryAction: @escaping () -> Void) {
        self.id = course.id
        self.title = course.title
        self.isEnrolled = course.enrolled
        self.coverURLString = course.coverURLString
        self.rating = course.reviewSummary?.average
        self.learners = course.learnersCount
        self.progress = course.enrolled ? course.progress?.percentPassed : nil
        self.action = action
        self.secondaryAction = secondaryAction
    }
}

enum CourseListColorMode {
    case light
    case dark
}

enum CourseListState {
    case emptyRefreshing
    case empty
    case emptyAnonymous
    case emptyError
    case displayingWithRefreshing
    case displaying
    case displayingWithError
}

enum PaginationStatus {
    case loading, error, none
}

enum CourseListType {
    case enrolled
    case popular
    case collection(ids: [Int])
    case search(query: String)
    case tag(id: Int)

    private func requestAllEnrolled(coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI) -> Promise<([Course], Meta)>? {
        return Promise {
            fulfill, reject in
            loadPageWithProgresses(loadedCourses: [], page: 1, coursesAPI: coursesAPI, progressesAPI: progressesAPI, success: {
                courses, meta in
                let res = courses.sorted(by: {
                    guard let lastViewed1 = $0.progress?.lastViewed, let lastViewed2 = $1.progress?.lastViewed else {
                        return false
                    }
                    return lastViewed1 > lastViewed2
                })
                fulfill((res, meta))
            }, error: {
                error in
                reject(error)
            })
        }
    }

    private func loadPageWithProgresses(loadedCourses: [Course], page: Int, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI, success: @escaping ([Course], Meta) -> Void, error errorHandler: @escaping (Error) -> Void) {

        coursesAPI.retrieve(enrolled: true, order: "-activity", page: page).then {
            courses, meta -> Void in

            guard !courses.isEmpty else {
                success(loadedCourses, meta)
                return
            }

            var progressIds: [String] = []
            var progresses: [Progress] = []
            for course in courses {
                if let progressId = course.progressId {
                    progressIds += [progressId]
                }
                if let progress = course.progress {
                    progresses += [progress]
                }
            }

            //Not calling this in next "then" because courses values are needed to proceed further
            progressesAPI.getObjectsByIds(ids: progressIds, updating: progresses).then {
                newProgresses -> Void in
                let progresses = Sorter.sort(newProgresses, byIds: progressIds)

                if progresses.count == 0 {
                    CoreDataHelper.instance.save()
                    return
                }

                var progressCnt = 0
                for i in 0 ..< courses.count {
                    if courses[i].progressId == progresses[progressCnt].id {
                        courses[i].progress = progresses[progressCnt]
                        progressCnt += 1
                    }
                    if progressCnt == progresses.count {
                        break
                    }
                }
                CoreDataHelper.instance.save()
                if meta.hasNext {
                    self.loadPageWithProgresses(loadedCourses: loadedCourses + courses, page: page + 1, coursesAPI: coursesAPI, progressesAPI: progressesAPI, success: success, error: errorHandler)
                } else {
                    success(loadedCourses + courses, meta)
                }
            }.catch {
                error in
                errorHandler(error)
            }
        }.catch {
            error in
            errorHandler(error)
        }
    }

    func request(page: Int, language: ContentLanguage, withAPI coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI, searchResultsAPI: SearchResultsAPI) -> Promise<([Course], Meta)>? {

        let requestedLanguage: ContentLanguage? = language == .russian ? nil : language

        switch self {
        case .popular:
            return coursesAPI.retrieve(excludeEnded: true, isPublic: true, order: "-activity", language: requestedLanguage, page: page)
        case .enrolled:
            return requestAllEnrolled(coursesAPI: coursesAPI, progressesAPI: progressesAPI)
        case let .search(query: query):
            var resultMeta: Meta = Meta(hasNext: false, hasPrev: false, page: 1)
            var searchCoursesIDs: [Int] = []
            return Promise<([Course], Meta)> {
                fulfill, reject in
                searchResultsAPI.searchCourse(query: query, language: requestedLanguage, page: page).then {
                    (searchResults, meta) -> Promise<([Course])> in
                    resultMeta = meta
                    searchCoursesIDs = searchResults.flatMap { $0.courseId }
                    return coursesAPI.retrieve(ids: searchCoursesIDs, existing: Course.getCourses(searchCoursesIDs))
                    }.then {
                        (courses) -> Void in
                        let resultCourses = Sorter.sort(courses, byIds: searchCoursesIDs)
                        fulfill((resultCourses, resultMeta))
                    }.catch {
                        error in
                        reject(error)
                }
            }
        case let .tag(id: id):
            return coursesAPI.retrieve(tag: id, language: requestedLanguage, page: page)
        default:
            return nil
        }
    }

    func request(coursesWithIds ids: [Int], withAPI coursesAPI: CoursesAPI) -> Promise<[Course]>? {
        switch self {
        case let .collection(ids: ids):
            return coursesAPI.retrieve(ids: ids, existing: Course.getCourses(ids))
        default:
            return nil
        }
    }

    private var cacheId: String? {
        switch self {
        case .popular:
            return "PopularCoursesInfo_\(ContentLanguage.sharedContentLanguage.languageString)"
        case .enrolled:
            return "MyCoursesInfo"
        default:
            return nil
        }
    }

    var cachedListCourseIds: [Int] {
        get {
            guard let cacheId = self.cacheId, let ids = UserDefaults.standard.object(forKey: cacheId) as? [Int] else {
                switch self {
                case let .collection(ids: ids):
                    return ids
                default:
                    return []
                }
            }
            return ids
        }

        set(newIds) {
            guard let cacheId = self.cacheId else {
                return
            }
            UserDefaults.standard.set(newIds, forKey: cacheId)
            UserDefaults.standard.synchronize()
        }
    }
}
