//
//  CatalogPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 12.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class UserCourses {
    private var passed: [ItemViewData] = []
    private var notpassed: [ItemViewData] = []

    private(set) var isLoaded = false

    init() {}

    func getCountWithIndexPath() -> [IndexPath: Int] {
        let aIndexPath = IndexPath(row: 0, section: 0)
        let bIndexPath = IndexPath(row: 1, section: 0)

        return [aIndexPath: getCourses(by: aIndexPath).count, bIndexPath: getCourses(by: bIndexPath).count]
    }

    func getCourses(by indexPath: IndexPath) -> [ItemViewData] {
        if indexPath.row == 0 { return notpassed }
        if indexPath.row == 1 { return passed }
        fatalError()
    }

    func setData(passed: [ItemViewData], notpassed: [ItemViewData]) {
        self.passed = passed
        self.notpassed = notpassed

        isLoaded = true
    }

    func addCourses(passed: [ItemViewData], notpassed: [ItemViewData]) {
        self.passed.append(contentsOf: passed)
        self.notpassed.append(contentsOf: notpassed)
    }

    func removePassed(withId id: Int) {
        passed = passed.filter { $0.id != id }
    }

    func removeNotpassed(withId id: Int) {
        notpassed = notpassed.filter { $0.id != id }
    }
}

struct DetailCatalogViewInfo {
    var detailView: CatalogDetailView
    var indexPath: IndexPath

    init(detailView: CatalogDetailView, indexPath: IndexPath) {
        self.detailView = detailView
        self.indexPath = indexPath
    }

    func provideCourses(with data: UserCourses) {
        detailView.provide(items: data.getCourses(by: indexPath))
    }
}

class CatalogPresenter {

    private let listType = CourseListType.enrolled

    weak var splitview: MenuSplitView?
    weak var masterview: CatalogMenuView?
    private var currentDetailViewInfo: DetailCatalogViewInfo?

    private var coursesAPI: CoursesAPI
    private var progressesAPI: ProgressesAPI
    private var searchResultsAPI: SearchResultsAPI = SearchResultsAPI()

    private var courses: [Course]?
    private var userCourses: UserCourses = UserCourses()

    private let didntLoggedAlertMessage = NSLocalizedString("Please, log in to see the user courses catalog", comment: "")
    private let alertButtonTitle = NSLocalizedString("Profile", comment: "")

    init(splitview: MenuSplitView, masterview: CatalogMenuView, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI) {
        self.splitview = splitview
        self.masterview = masterview
        self.coursesAPI = coursesAPI
        self.progressesAPI = progressesAPI

        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedInNotification(_:)), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedOutNotification(_:)), name: .userLoggedOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.courseSubscribedNotification(_:)), name: .courseSubscribed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.courseUnsubscribedNotification(_:)), name: .courseUnsubscribed, object: nil)
    }

    func refresh() {
        //view?.setConnectionProblemsPlaceholder(hidden: true)
        let language = ContentLanguage.sharedContentLanguage
        refreshCourses(for: language)
    }

    func setDetailViewToProvideData(_ detailView: CatalogDetailView, width: Float, by indexPath: IndexPath) {
        currentDetailViewInfo = DetailCatalogViewInfo(detailView: detailView, indexPath: indexPath)

        if !userCourses.isLoaded { currentDetailViewInfo?.detailView.showLoading(with: width) }
        //currentDetailViewInfo?.detailView.showLoading(isVisible: !userCourses.isLoaded)
        currentDetailViewInfo?.provideCourses(with: userCourses)
    }

    private func refreshCourses(for language: ContentLanguage) {
        coursesAPI.cancelAllTasks()
        switch listType {
        case .enrolled:
            if !AuthInfo.shared.isAuthorized {
                self.courses = nil
                self.userCourses = UserCourses()

                splitview?.showMessageOver(didntLoggedAlertMessage, buttonTitle: alertButtonTitle) {
                    let view = self.splitview as! UIViewController
                    view.tabBarController?.selectedIndex = 2
                }
                return
            }
            //splitview?.hideMessageOver()
            requestEnrolled(updateProgresses: false, language: language) {
                [weak self]
                _ in

                self?.userCourses.getCountWithIndexPath().forEach {
                    self?.masterview?.provide(count: $0.value, at: $0.key)
                }
                self?.currentDetailViewInfo?.detailView.hideLoading()
                self?.currentDetailViewInfo?.provideCourses(with: self!.userCourses)
            }
        default:
            fatalError()
        }
    }

    private func requestEnrolled(updateProgresses: Bool, language: ContentLanguage, completion: (() -> Void)? = nil) {
        listType.request(page: 1, language: language, withAPI: coursesAPI, progressesAPI: progressesAPI, searchResultsAPI: searchResultsAPI)?.then {
            [weak self]
            (courses, _) -> Void in
            guard let strongSelf = self else {
                completion?()
                return
            }

            strongSelf.courses = courses
            let passedCourses = courses.filter { $0.progress?.percentPassed == 1.0 }
            let notpassedCourses = courses.filter { $0.progress?.percentPassed != 1.0 }

            guard let passedViewData = strongSelf.buildViewData(from: passedCourses), let notpassedViewData = strongSelf.buildViewData(from: notpassedCourses) else { return }

            strongSelf.userCourses.setData(passed: passedViewData, notpassed: notpassedViewData)

            completion?()
        }.catch {
            _ in
            print("Error while refreshing collection")
            completion?()
        }
    }

    private func buildViewData(from courses: [Course]) -> [ItemViewData]? {
        guard let viewController = masterview as? UIViewController else { print("lose view"); return nil }

        return courses.map { course in
            ItemViewData(placeholder: #imageLiteral(resourceName: "placeholder"), imageURLString: course.coverURLString, id: course.id, title: course.title) {
                ScreensTransitions.moveToCourseContent(from: viewController, for: course)
            }
        }
    }

    @objc private func courseSubscribedNotification(_ notification: NSNotification) {
        if let course = notification.userInfo?["course"] as? Course {

            guard let percent = course.progress?.percentPassed else { return }
            guard let viewData = buildViewData(from: [course]) else { return }

            if percent < 1.0 {
                userCourses.addCourses(passed: [], notpassed: viewData)
            } else {
                userCourses.addCourses(passed: viewData, notpassed: [])
            }

            // Provide data to view
            userCourses.getCountWithIndexPath().forEach {
                self.masterview?.provide(count: $0.value, at: $0.key)
            }
            currentDetailViewInfo?.provideCourses(with: self.userCourses)
        }
    }

    @objc private func courseUnsubscribedNotification(_ notification: NSNotification) {
        if let id = notification.userInfo?["id"] as? Int {
            userCourses.removeNotpassed(withId: id)
            userCourses.removePassed(withId: id)

            // Provide data to view
            userCourses.getCountWithIndexPath().forEach {
                self.masterview?.provide(count: $0.value, at: $0.key)
            }
            currentDetailViewInfo?.provideCourses(with: self.userCourses)
        }
    }

    @objc private func userLoggedInNotification(_ notification: NSNotification) {
        splitview?.hideMessageOver()
        refresh()
    }

    @objc private func userLoggedOutNotification(_ notification: NSNotification) {
        self.courses = nil
        self.userCourses = UserCourses()
        self.currentDetailViewInfo?.provideCourses(with: userCourses)

        splitview?.showMessageOver(didntLoggedAlertMessage, buttonTitle: alertButtonTitle) {
            let view = self.splitview as! UIViewController

            view.tabBarController?.selectedIndex = 2
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
