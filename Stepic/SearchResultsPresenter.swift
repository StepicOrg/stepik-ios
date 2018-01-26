//
//  SearchResultsPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol SearchResultsView: class {
    func set(state: CoursesSearchResultsState)
    func set(controller: UIViewController, forState: CoursesSearchResultsState)
}

class SearchResultsPresenter {
    weak var view: SearchResultsView?

    var updateQueryBlock: ((String) -> Void)?
    var hideKeyboardBlock: (() -> Void)?

    //TODO: Somehow refactor this
    private var suggestionsVC: SearchQueriesViewController?
    private var resultsVC: CourseListVerticalViewController?

    var query: String = ""

    init(view: SearchResultsView) {
        self.view = view
    }

    func queryChanged(to query: String) {
        self.query = query
        guard query != "" else {
            view?.set(state: .waiting)
            resultsVC = nil
            suggestionsVC = nil
            return
        }
        if suggestionsVC == nil {
            suggestionsVC = SearchQueriesViewController()
            suggestionsVC?.delegate = self
            suggestionsVC?.hideKeyboardBlock = self.hideKeyboardBlock
            self.view?.set(controller: suggestionsVC!, forState: .suggestions)
        }
        suggestionsVC?.query = query
        view?.set(state: .suggestions)
        resultsVC = nil
    }

    func search(query: String) {
        self.query = query
        if resultsVC == nil {
            resultsVC = ControllerHelper.instantiateViewController(identifier: "CourseListVerticalViewController", storyboardName: "CourseLists") as? CourseListVerticalViewController
            if let resultsVC = resultsVC {
                resultsVC.presenter = CourseListPresenter(view: resultsVC, ID: "SearchCourses", limit: nil, listType: .search(query: query), colorMode: .light, onlyLocal: false, subscriptionManager: CourseSubscriptionManager(), coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI(), searchResultsAPI: SearchResultsAPI(), subscriber: CourseSubscriber(), adaptiveStorageManager: AdaptiveStorageManager())
                self.view?.set(controller: resultsVC, forState: .courses)
            }
        } else {
            //Don't actually know if this code is ever being executed
            resultsVC?.presenter?.listType = .search(query: query)
            resultsVC?.presenter?.refresh()
        }
        view?.set(state: .courses)
        suggestionsVC = nil
    }

    func searchStarted() {
        queryChanged(to: query)
    }

    func searchCancelled() {
        query = ""
    }
}

extension SearchResultsPresenter: SearchQueriesViewControllerDelegate {
    func didSelectSuggestion(suggestion: String, position: Int) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Search.selected, parameters: ["query": self.query.lowercased(), "position": position, "suggestion": suggestion])
        search(query: suggestion)
        updateQueryBlock?(suggestion)
    }
}

enum CoursesSearchResultsState {
    case waiting, suggestions, courses
}
