//
//  SearchResultsPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol SearchResultsView: AnyObject {
    func set(state: CoursesSearchResultsState)
    func set(controller: UIViewController, forState: CoursesSearchResultsState)
}

final class SearchResultsPresenter: SearchResultsModuleInputProtocol {
    weak var view: SearchResultsView?

    var updateQueryBlock: ((String) -> Void)?

    //TODO: Somehow refactor this
    private var suggestionsVC: SearchQueriesViewController?
    private var resultsVC: UIViewController?

    var query: String = ""
    private var currentCourseListFilterQuery: CourseListFilterQuery?

    private let analytics: Analytics

    init(view: SearchResultsView, analytics: Analytics) {
        self.view = view
        self.analytics = analytics
    }

    func queryChanged(to query: String) {
        self.query = query

        if suggestionsVC == nil {
            suggestionsVC = SearchQueriesViewController()
            suggestionsVC?.delegate = self
            self.view?.set(controller: suggestionsVC!, forState: .suggestions)
        }
        suggestionsVC?.query = query
        view?.set(state: .suggestions)
        resultsVC = nil
    }

    func filterQueryChanged(to query: CourseListFilterQuery?) {
        if self.currentCourseListFilterQuery == query {
            return
        }

        self.currentCourseListFilterQuery = query

        if self.resultsVC != nil {
            self.resultsVC = nil
            self.search(query: self.query)
        }
    }

    func search(query: String) {
        self.query = query
        if resultsVC == nil {
            let resultsVC = FullscreenCourseListAssembly(
                presentationDescription: nil,
                courseListType: SearchResultCourseListType(
                    query: query,
                    filterQuery: self.currentCourseListFilterQuery,
                    language: ContentLanguageService().globalContentLanguage
                ),
                courseViewSource: .search(query: query)
            ).makeModule()
            self.resultsVC = resultsVC
            self.view?.set(controller: resultsVC, forState: .courses)
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
        self.analytics.send(
            .courseSearched(
                query: self.query.lowercased(),
                position: position,
                suggestion: suggestion.lowercased()
            )
        )
        search(query: suggestion)
        updateQueryBlock?(suggestion)
    }
}

enum CoursesSearchResultsState {
    case waiting
    case suggestions
    case courses
}
