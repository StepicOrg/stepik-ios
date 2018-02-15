//
//  SearchResultsPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 06.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class SearchResultsPresenter {

    weak var view: SearchResultsView?
    private var coursesAPI: CoursesAPI
    private var progressesAPI: ProgressesAPI
    private var searchResultsAPI: SearchResultsAPI

    private var filterString: String = "" {
        didSet {
            // Return if the filter string hasn't changed.
            guard filterString != oldValue else { return }
            guard filterString != "" else { view?.provide(items: []); return }

            let language = ContentLanguage.sharedContentLanguage

            view?.showLoading(isVisible: true)
            request(forQuery: filterString, forLanguage: language) {
                [weak self]
                _ in

                self?.view?.showLoading(isVisible: false)
            }
        }
    }
    private var appropriateCourses: [ItemViewData] = [] {
        didSet {
            view?.provide(items: appropriateCourses)
        }
    }

    init(view: SearchResultsView, coursesAPI: CoursesAPI, progressesAPI: ProgressesAPI, searchResultsAPI: SearchResultsAPI) {
        self.view = view
        self.coursesAPI = coursesAPI
        self.progressesAPI = progressesAPI
        self.searchResultsAPI = searchResultsAPI
    }

    func updateSearchQuery(with text: String) {
        filterString = text
    }

    private func request(forQuery query: String, forLanguage language: ContentLanguage, completion: (() -> Void)? = nil) {
        print(query)
        view?.provide(items: [])

        searchResultsAPI.cancelAllTasks()

        let searchType = CourseListType.search(query: query)
        searchType.request(page: 1, language: language, withAPI: coursesAPI, progressesAPI: progressesAPI, searchResultsAPI: searchResultsAPI)?.then {
            [weak self]
            (courses, _) -> Void in
            guard let strongSelf = self else {
                completion?()
                return
            }

            print(courses.count)
            if let courses = strongSelf.buildViewData(from: courses) {
                strongSelf.appropriateCourses = courses
            }

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
            ItemViewData(placeholder: #imageLiteral(resourceName: "placeholderEmpty"), imageURLString: course.coverURLString, id: course.id, title: course.title) {

                guard course.enrolled else {
                    ScreensTransitions.moveToCourseInformationScreen(from: viewController, for: course)
                    return
                }

                ScreensTransitions.moveToCourseContent(from: viewController, for: course)
            }
        }
    }
}
