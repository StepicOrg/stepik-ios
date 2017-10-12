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

    func setRefreshing(isRefreshing: Bool)
    func setPaginationStatus(status: PaginationStatus)

    func present(controller: UIViewController)
    func show(controller: UIViewController)
}

class CourseListPresenter {
    private var coursesAPI: CoursesAPI
    private var progressesAPI: ProgressesAPI
    private var reviewSummariesAPI: CourseReviewSummariesAPI

    private weak var view: CourseListView?
    private var limit: Int?
    private var listType: CourseListType

    private var currentPage: Int = 1
    private var hasNextPage: Bool = false

    private var shouldLoadNextPage: Bool {
        if let limit = limit {
            return hasNextPage && courses.count < limit
        } else {
            return hasNextPage
        }
    }

    private var courses: [Course] = [] {
        didSet {
            if let limit = limit {
                displayingCourses = [Course](courses.prefix(limit))
            } else {
                displayingCourses = courses
            }
        }
    }
    private var displayingCourses: [Course] = []

    init(view: CourseListView, limit: Int?, listType: CourseListType, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI, reviewSummariesAPI: CourseReviewSummariesAPI) {
        self.view = view
        self.coursesAPI = coursesAPI
        self.progressesAPI = progressesAPI
        self.reviewSummariesAPI = reviewSummariesAPI
        self.limit = limit
        self.listType = listType
    }

    func refresh() {
        view?.setRefreshing(isRefreshing: true)
        switch listType {
        case let .enrolled(cachedIds: cachedIds), let .popular(cachedIds: cachedIds), let .collection(ids: cachedIds):
            if courses.isEmpty {
                displayCached(ids: cachedIds)
            }
            refreshCourses()
        }
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
            strongSelf.view?.add(addedCourses: CourseViewData.getData(from: strongSelf.getDisplayingFrom(newCourses: courses)), courses: CourseViewData.getData(from: strongSelf.displayingCourses))
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

    private func displayCached(ids: [Int]) {
        let recoveredCourses = try! Course.getCourses(ids)
        courses = Sorter.sort(recoveredCourses, byIds: ids)
    }

    private func refreshCourses() {
        if courses.isEmpty {
            self.view?.setRefreshing(isRefreshing: true)
        }
        coursesAPI.cancelAllTasks()
        switch listType {
        case let .collection(ids: ids):
            listType.request(coursesWithIds: ids, withAPI: coursesAPI)?.then {
                [weak self]
                courses -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.courses = courses
                strongSelf.view?.display(courses: CourseViewData.getData(from: strongSelf.displayingCourses))
                strongSelf.updateReviewSummaries(for: courses)
                strongSelf.updateProgresses(for: courses)
                strongSelf.currentPage = 1
                strongSelf.hasNextPage = false
                strongSelf.view?.setPaginationStatus(status: strongSelf.shouldLoadNextPage ? .loading : .none)
            }.always {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view?.setRefreshing(isRefreshing: false)
            }.catch {
                _ in
                print("Error while refreshing collection")
            }
        default:
            listType.request(page: 1, withAPI: coursesAPI)?.then {
                [weak self]
                (courses, meta) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.courses = courses
                strongSelf.view?.display(courses: CourseViewData.getData(from: strongSelf.displayingCourses))
                strongSelf.updateReviewSummaries(for: courses)
                strongSelf.updateProgresses(for: courses)
                strongSelf.currentPage = meta.page
                strongSelf.hasNextPage = meta.hasNext
                strongSelf.view?.setPaginationStatus(status: strongSelf.shouldLoadNextPage ? .loading : .none)
                }.always {
                    [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.view?.setRefreshing(isRefreshing: false)
                }.catch {
                    _ in
                    print("error while refreshing course collection")
            }
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

    private func getDisplayingFrom(newCourses: [Course]) -> [Course] {
        var result: [Course] = []
        for course in displayingCourses {
            if newCourses.index(of: course) != nil {
                result += [course]
            }
        }
        return result
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
            strongSelf.view?.update(updatedCourses: CourseViewData.getData(from: strongSelf.getDisplayingFrom(newCourses: courses)), courses: CourseViewData.getData(from: strongSelf.displayingCourses))
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
            strongSelf.view?.update(updatedCourses: CourseViewData.getData(from: strongSelf.getDisplayingFrom(newCourses: courses)), courses: CourseViewData.getData(from: strongSelf.courses) )
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

    init(course: Course) {
        self.id = course.id
        self.title = course.title
        self.isEnrolled = course.enrolled
        self.coverURLString = course.coverURLString
        self.rating = course.reviewSummary?.average
        self.learners = course.learnersCount
        self.progress = course.enrolled ? course.progress?.percentPassed : nil
    }

    static func getData(from courses: [Course]) -> [CourseViewData] {
        return courses.map { CourseViewData(course: $0) }
    }
}

enum PaginationStatus {
    case loading, error, none
}

enum CourseListType {
    case enrolled(cachedIds: [Int])
    case popular(cachedIds: [Int])
    case collection(ids: [Int])

    func request(page: Int, withAPI coursesAPI: CoursesAPI) -> Promise<([Course], Meta)>? {
        switch self {
        case .popular(cachedIds: _):
            return coursesAPI.retrieve(featured: true, excludeEnded: true, isPublic: true, order: "-activity", page: page)
        case .enrolled(cachedIds: _):
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
}
