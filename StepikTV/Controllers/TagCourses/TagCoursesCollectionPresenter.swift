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

    private var items: [ItemViewData]?

    init(view: TagCoursesCollectionView, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI) {
        self.view = view
        self.coursesAPI = coursesAPI
        self.progressesAPI = progressesAPI
    }

    func refresh() {
        guard let listType = listType else { return }

        let listLanguage = ContentLanguage.sharedContentLanguage

        view?.showLoading(isVisible: true)
        requestForCourses(with: listType, forLanguage: listLanguage) {
            [weak self]
            _ in

            if let items = self?.items {
                self?.view?.provide(items: items)
            }
            self?.view?.showLoading(isVisible: false)
        }
    }

    private func requestForCourses(with listType: CourseListType, forLanguage language: ContentLanguage, completion: (() -> Void)? = nil) {

        listType.request(page: 1, language: language, withAPI: coursesAPI, progressesAPI: progressesAPI, searchResultsAPI: searchResultsAPI)?.then {
            [weak self]
            (courses, _) -> Void in
            guard let strongSelf = self else {
                completion?()
                return
            }

            strongSelf.items = strongSelf.buildViewData(from: courses)
            completion?()
        }.catch {
            _ in
            print("Error while refreshing collection")
            completion?()
        }
    }

    private func buildViewData(from courses: [Course]) -> [ItemViewData]? {
        guard let viewController = view as? UIViewController else { print("lose view"); return nil }

        return courses.map { course in
            ItemViewData(placeholder: #imageLiteral(resourceName: "placeholder"), imageURLString: course.coverURLString, title: course.title) {

                guard course.enrolled else {
                    ScreensTransitions.getTransitionToCourseInformationScreen(from: viewController, for: course)
                    return
                }

                ScreensTransitions.getTransitionToCourseContent(from: viewController, for: course)
            }
        }
    }
}
