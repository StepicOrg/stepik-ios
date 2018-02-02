//
//  CourseListPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TagCoursesCollectionPresenter {

    weak var view: TagCoursesCollectionView?
    private var coursesAPI: CoursesAPI
    private var progressesAPI: ProgressesAPI
    private var searchResultsAPI: SearchResultsAPI = SearchResultsAPI()

    var tag: CourseTag? {
        didSet {
            guard let tag = tag else { return }
            listType = CourseListType.tag(id: tag.ID)
        }
    }

    private var listType: CourseListType? {
        didSet {
            refresh()
        }
    }

    private var items: [ItemViewData]? {
        didSet {
            guard let items = items else { return }
            view?.provide(items: items)
        }
    }

    init(view: TagCoursesCollectionView, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI) {
        self.view = view
        self.coursesAPI = coursesAPI
        self.progressesAPI = progressesAPI

    }

    func refresh() {
        //view?.setConnectionProblemsPlaceholder(hidden: true)
        view?.showLoading(isVisible: true)

        let listLanguage = ContentLanguage.sharedContentLanguage
        requestForCourses(forLanguage: listLanguage) {
            self.view?.showLoading(isVisible: false)
        }
    }

    private func requestForCourses(forLanguage language: ContentLanguage, completion: (() -> Void)? = nil) {
        guard let listType = listType else { return }

        listType.request(page: 1, language: language, withAPI: coursesAPI, progressesAPI: progressesAPI, searchResultsAPI: searchResultsAPI)?.then {
            [weak self]
            (courses, meta) -> Void in
            guard let strongSelf = self else {
                return
            }

            strongSelf.items = strongSelf.buildViewData(from: courses)

            completion?()
        }.catch {
            [weak self]
            _ in
            guard let strongSelf = self else {
                return
            }
            print("Error while refreshing collection")
            completion?()
        }
    }

    private func buildViewData(from courses: [Course]) -> [ItemViewData]? {
        guard let viewController = view as? UIViewController else { print("lose view"); return nil }

        return courses.map { course in
            ItemViewData(placeholder: #imageLiteral(resourceName: "placeholder"), imageURLString: course.coverURLString, title: course.title) {

                let courseInfoVC = ControllerHelper.instantiateViewController(identifier: "CourseInfoPage", storyboardName: "CourseInfo") as! CourseInfoCollectionViewController

                courseInfoVC.presenter = CourseInfoPresenter(view: courseInfoVC)
                courseInfoVC.presenter?.course = course

                viewController.present(courseInfoVC, animated: true, completion: {})

                // if subscribed

//                let initialVC = ControllerHelper.instantiateViewController(identifier: "CourseContentInitial", storyboardName: "CourseContent") as! MenuSplitViewController
//
//                let navController = initialVC.viewControllers.first as! UINavigationController
//
//                let courseContentVC = navController.viewControllers.first as! CourseContentMenuViewController
//
//                courseContentVC.presenter = CourseContentPresenter(view: courseContentVC)
//                courseContentVC.presenter?.course = course
//
//                viewController.present(initialVC, animated: true, completion: {})
            }
        }
    }
}
