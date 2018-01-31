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
}

struct DetailCatalogViewInfo {
    var detailView: DetailCatalogView
    var indexPath: IndexPath

    init(detailView: DetailCatalogView, indexPath: IndexPath) {
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
    weak var masterview: CatalogView?
    private var currentDetailViewInfo: DetailCatalogViewInfo?

    private var coursesAPI: CoursesAPI
    private var progressesAPI: ProgressesAPI
    private var searchResultsAPI: SearchResultsAPI = SearchResultsAPI()

    private var courses: [Course]?
    private var userCourses: UserCourses = UserCourses()

    private let didntLoggedAlertMessage = NSLocalizedString("Please, log in to see the user courses catalog", comment: "")
    private let alertButtonTitle = NSLocalizedString("Profile", comment: "")

    init(splitview: MenuSplitView, masterview: CatalogView, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI) {
        self.splitview = splitview
        self.masterview = masterview
        self.coursesAPI = coursesAPI
        self.progressesAPI = progressesAPI

        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoginNotification), name: .userLogin, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.userLogoutNotification), name: .userLogout, object: nil)
    }

    func refresh() {
        //view?.setConnectionProblemsPlaceholder(hidden: true)
        let language = ContentLanguage.sharedContentLanguage
        refreshCourses(for: language)
    }

    func setDetailViewToProvideData(_ detailView: DetailCatalogView, by indexPath: IndexPath) {
        currentDetailViewInfo = DetailCatalogViewInfo(detailView: detailView, indexPath: indexPath)

        currentDetailViewInfo?.detailView.showLoading(isVisible: !userCourses.isLoaded)
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
            requestEnrolled(updateProgresses: false, language: language)
        default:
            fatalError()
        }
    }

    private func requestEnrolled(updateProgresses: Bool, language: ContentLanguage) {
        listType.request(page: 1, language: language, withAPI: coursesAPI, progressesAPI: progressesAPI, searchResultsAPI: searchResultsAPI)?.then {
            [weak self]
            (courses, _) -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.courses = courses
            let passedCourses = courses.filter { $0.progress?.percentPassed == 1.0 }
            let notpassedCourses = courses.filter { $0.progress?.percentPassed != 1.0 }
            let passedViewData = strongSelf.buildViewData(from: passedCourses)
            let notpassedViewData = strongSelf.buildViewData(from: notpassedCourses)

            strongSelf.userCourses.setData(passed: passedViewData, notpassed: notpassedViewData)

            strongSelf.userCourses.getCountWithIndexPath().forEach {
                strongSelf.masterview?.provide(count: $0.value, at: $0.key)
            }

            strongSelf.currentDetailViewInfo?.detailView.showLoading(isVisible: false)
            strongSelf.currentDetailViewInfo?.provideCourses(with: strongSelf.userCourses)
            }.catch {
                [weak self]
                _ in
                guard let strongSelf = self else {
                    return
                }
                print("Error while refreshing collection")
        }
    }

    private func buildViewData(from courses: [Course]) -> [ItemViewData] {
        guard let viewController = masterview as? UIViewController else { fatalError() }
        return courses.map { course in
            ItemViewData(placeholder: #imageLiteral(resourceName: "placeholder"), imageURLString: course.coverURLString, title: course.title) {

                let initialVC = ControllerHelper.instantiateViewController(identifier: "CourseContentInitial", storyboardName: "CourseContent") as! MenuSplitViewController

                let navController = initialVC.viewControllers.first as! UINavigationController

                let courseContentVC = navController.viewControllers.first as! CourseContentMenuViewController

                courseContentVC.presenter = CourseContentPresenter(view: courseContentVC)
                courseContentVC.presenter?.course = course

                viewController.present(initialVC, animated: true, completion: {})
            }
        }
    }

    @objc private func userLoginNotification() {
        splitview?.hideMessageOver()
        refresh()
    }

    @objc private func userLogoutNotification() {
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
