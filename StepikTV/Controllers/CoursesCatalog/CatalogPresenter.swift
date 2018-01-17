//
//  CatalogPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 12.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

struct UserCourses {
    private var passed: [ItemViewData]
    private var notpassed: [ItemViewData]

    init(passed: [ItemViewData], notpassed: [ItemViewData]) {
        self.passed = passed
        self.notpassed = notpassed
    }

    func getCourses(by indexPath: IndexPath) -> [ItemViewData] {
        if indexPath.row == 0 { return notpassed }
        if indexPath.row == 1 { return passed }
        fatalError()
    }
}

class CatalogPresenter {

    private let listType = CourseListType.enrolled

    weak var view: CatalogView?

    private var coursesAPI: CoursesAPI
    private var progressesAPI: ProgressesAPI
    private var searchResultsAPI: SearchResultsAPI = SearchResultsAPI()

    private var courses: [Course]?
    private var userCourses: UserCourses? {
        didSet {
            guard let data = userCourses else { return }
            view?.provide(userCourses: data)
        }
    }

    init(view: CatalogView, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI) {
        self.view = view
        self.coursesAPI = coursesAPI
        self.progressesAPI = progressesAPI
    }

    func refresh() {
        //view?.setConnectionProblemsPlaceholder(hidden: true)
        let language = ContentLanguage.sharedContentLanguage
        refreshCourses(for: language)
    }

    private func refreshCourses(for language: ContentLanguage) {
        coursesAPI.cancelAllTasks()
        switch listType {
        case .enrolled:
            if !AuthInfo.shared.isAuthorized {
                self.courses = []
                self.view?.notifyNotAuthorized()
                print("crack")
                return
            }
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
            strongSelf.userCourses = UserCourses(passed: passedViewData, notpassed: notpassedViewData)
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
        guard let viewController = view as? UIViewController else { fatalError() }
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
}
