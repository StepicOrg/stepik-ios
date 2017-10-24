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

//    func setRefreshing(isRefreshing: Bool)
    func setPaginationStatus(status: PaginationStatus)

    func present(controller: UIViewController)
    func show(controller: UIViewController)

    var colorMode: CourseListColorMode! { get set }

    func getNavigationController() -> UINavigationController?
}

class CourseListPresenter {
    private var coursesAPI: CoursesAPI
    private var progressesAPI: ProgressesAPI
    private var reviewSummariesAPI: CourseReviewSummariesAPI

    private var colorMode: CourseListColorMode

    private weak var view: CourseListView?
    private var limit: Int?
    private var listType: CourseListType

    private var currentPage: Int = 1
    private var hasNextPage: Bool = false

    private var lastUser: User?

    private var subscriptionManager = CourseSubscriptionManager()

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
            if let limit = limit {
                displayingCourses = [Course](courses.prefix(limit))
            } else {
                displayingCourses = courses
            }
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

    init(view: CourseListView, limit: Int?, listType: CourseListType, colorMode: CourseListColorMode, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI, reviewSummariesAPI: CourseReviewSummariesAPI) {
        self.view = view
        self.coursesAPI = coursesAPI
        self.progressesAPI = progressesAPI
        self.reviewSummariesAPI = reviewSummariesAPI
        self.limit = limit
        self.listType = listType
        self.colorMode = colorMode
        subscriptionManager.startObservingOtherSubscriptionmanagers()
        subscriptionManager.handleUpdatesBlock = {
            [weak self] in
            self?.handleCourseSubscriptionUpdates()
        }
        view.colorMode = colorMode
    }

    func getData(from courses: [Course]) -> [CourseViewData] {
        return courses.map {
            course in
            CourseViewData(course: course, action: {
                [weak self] in
                self?.buttonPressed(course: course)
            })
        }
    }

    private func buttonPressed(course: Course) {
        if course.enrolled {
            if let navigation = view?.getNavigationController() {
                LastStepRouter.continueLearning(for: course, using: navigation)
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
        refreshCourses()
    }

    func loadNextPage() {
        guard self.hasNextPage else {
            return
        }
        self.view?.setPaginationStatus(status: .loading)
        coursesAPI.cancelAllTasks()
        listType.request(page: currentPage + 1, withAPI: coursesAPI)?.then {
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

    func willAppear() {
        if lastUser != AuthInfo.shared.user {
            refresh()
            return
        } else {
            handleCourseSubscriptionUpdates()
        }
    }

    func handleCourseSubscriptionUpdates() {
        //TODO: Add subscription updates for other types of courses (change button types & remove/add progress)
        guard subscriptionManager.hasUpdates else {
            return
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

            view?.update(deletingIds: deletedIds, insertingIds: addedIds, courses: getData(from: newDisplayedCourses))
        default:
            let updatedCourses = subscriptionManager.addedCourses + subscriptionManager.deletedCourses
            self.view?.update(updatedCourses: getData(from: getDisplaying(from: updatedCourses)), courses: getData(from: getDisplaying(from: courses)))
            return
        }
    }

    private func displayCached(ids: [Int]) {
        let recoveredCourses = try! Course.getCourses(ids)
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

    private func requestNonCollection() {
        listType.request(page: 1, withAPI: coursesAPI)?.then {
            [weak self]
            (courses, meta) -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.courses = courses
            strongSelf.view?.display(courses: strongSelf.getData(from: strongSelf.displayingCourses))
            strongSelf.updateReviewSummaries(for: courses)
            strongSelf.updateProgresses(for: courses)
            strongSelf.currentPage = meta.page
            strongSelf.hasNextPage = meta.hasNext
            strongSelf.view?.setPaginationStatus(status: strongSelf.shouldLoadNextPage ? .loading : .none)
            strongSelf.state = courses.isEmpty ? .empty: .displaying
            }.catch {
                [weak self]
                _ in
                guard let strongSelf = self else {
                    return
                }
                print("Error while refreshing collection")
                strongSelf.state = strongSelf.courses.isEmpty ? .emptyError : .displayingWithError
        }
    }

    private func refreshCourses() {
        coursesAPI.cancelAllTasks()
        lastUser = AuthInfo.shared.user
        switch listType {
        case let .collection(ids: ids):
            state = courses.isEmpty ? .emptyRefreshing : .displayingWithRefreshing
            listType.request(coursesWithIds: ids, withAPI: coursesAPI)?.then {
                [weak self]
                courses -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.courses = courses
                strongSelf.view?.display(courses: strongSelf.getData(from: strongSelf.displayingCourses))
                strongSelf.updateReviewSummaries(for: courses)
                strongSelf.updateProgresses(for: courses)
                strongSelf.currentPage = 1
                strongSelf.hasNextPage = false
                strongSelf.view?.setPaginationStatus(status: strongSelf.shouldLoadNextPage ? .loading : .none)
                strongSelf.state = courses.isEmpty ? .empty: .displaying
            }.catch {
                [weak self]
                _ in
                guard let strongSelf = self else {
                    return
                }
                print("Error while refreshing collection")
                strongSelf.state = strongSelf.courses.isEmpty ? .emptyError : .displayingWithError
            }
        case .enrolled:
            if !AuthInfo.shared.isAuthorized {
                self.state = .emptyAnonymous
            } else {
                state = courses.isEmpty ? .emptyRefreshing : .displayingWithRefreshing
            }
            requestNonCollection()
        default:
            state = courses.isEmpty ? .emptyRefreshing : .displayingWithRefreshing
            requestNonCollection()
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

    func didSelectCourse(at index: Int) {
        let course = courses[index]
        let controller = course.enrolled ? getSectionsController(for: course) : getCoursePreviewController(for: course)
        if let controller = controller {
            self.view?.show(controller: controller)
        }
    }

    // Progresses

    private func updateProgresses(for courses: [Course]) {
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

        progressesAPI.getObjectsByIds(ids: progressIds, updating: progresses).then {
            [weak self]
            newProgresses -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.matchProgresses(newProgresses: newProgresses, ids: progressIds, courses: courses)
            strongSelf.view?.update(updatedCourses: strongSelf.getData(from: strongSelf.getDisplaying(from: courses)), courses: strongSelf.getData(from: strongSelf.displayingCourses))
        }.catch {
            _ in
            print("Error while loading progresses")
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

    init(course: Course, action: (() -> Void)?) {
        self.id = course.id
        self.title = course.title
        self.isEnrolled = course.enrolled
        self.coverURLString = course.coverURLString
        self.rating = course.reviewSummary?.average
        self.learners = course.learnersCount
        self.progress = course.enrolled ? course.progress?.percentPassed : nil
        self.action = action
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

    func request(page: Int, withAPI coursesAPI: CoursesAPI) -> Promise<([Course], Meta)>? {
        switch self {
        case .popular:
            return coursesAPI.retrieve(featured: true, excludeEnded: true, isPublic: true, order: "-activity", page: page)
        case .enrolled:
            return coursesAPI.retrieve(enrolled: true, order: "-activity", page: page)
        default:
            return nil
        }
    }

    func request(coursesWithIds ids: [Int], withAPI coursesAPI: CoursesAPI) -> Promise<[Course]>? {
        switch self {
        case let .collection(ids: ids):
            return coursesAPI.retrieve(ids: ids, existing: try! Course.getCourses(ids))
        default:
            return nil
        }
    }

    private var cacheId: String? {
        switch self {
        case .popular:
            return "PopularCoursesInfo"
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
