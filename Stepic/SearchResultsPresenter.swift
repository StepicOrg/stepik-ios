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

class SearchResultsPresenter: SearchResultsModuleInputProtocol {
    weak var view: SearchResultsView?

    var updateQueryBlock: ((String) -> Void)?

    //TODO: Somehow refactor this
    private var suggestionsVC: SearchQueriesViewController?
    private var resultsVC: UIViewController?

    var query: String = ""

    init(view: SearchResultsView) {
        self.view = view
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

    func search(query: String) {
        self.query = query
        if resultsVC == nil {
            let resultsVC = FullscreenCourseListAssembly(
                presentationDescription: nil,
                courseListType: SearchResultCourseListType(
                    query: query,
                    language: ContentLanguageService().globalContentLanguage
                )
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
        AnalyticsReporter.reportEvent(AnalyticsEvents.Search.selected, parameters: ["query": self.query.lowercased(), "position": position, "suggestion": suggestion])
        AmplitudeAnalyticsEvents.Search.searched(query: self.query.lowercased(), position: position, suggestion: suggestion.lowercased()).send()
        search(query: suggestion)
        updateQueryBlock?(suggestion)
    }
}

enum CoursesSearchResultsState {
    case waiting, suggestions, courses
}
