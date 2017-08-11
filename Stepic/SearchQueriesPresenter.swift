//
//  SearchQueriesPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire

class SearchQueriesPresenter {
    weak var view: SearchQueriesView?
    var queriesAPI: QueriesAPI

    var currentRequest: Request?
    var persistentManager: SearchQueriesPersistentManager

    let localSuggestionsMaxCount = 3

    init(view: SearchQueriesView, queriesAPI: QueriesAPI, persistentManager: SearchQueriesPersistentManager) {
        self.queriesAPI = queriesAPI
        self.view = view
        self.persistentManager = persistentManager
    }

    func getSuggestions(query: String) {
        let localSuggestions = [query.lowercased()] + persistentManager.getTop(for: query, count: localSuggestionsMaxCount)
        self.view?.updateSuggestions(suggestions: localSuggestions)
        currentRequest?.cancel()
        self.view?.setState(state: .updating)
        self.currentRequest = self.queriesAPI.retrieve(query: query.lowercased(), success: {
            [weak self]
            suggestions in
            let uniqueSuggestions = NSOrderedSet(array: localSuggestions + suggestions.map({$0.lowercased()})).array as? [String] ?? (localSuggestions + suggestions)
            self?.view?.updateSuggestions(suggestions: uniqueSuggestions)
            self?.view?.setState(state: .ok)
        }, error: {
            [weak self]
            error in
            if error != .cancelled {
                self?.view?.setState(state: .error)
            } else {
                self?.view?.setState(state: .ok)
            }
        })
    }

    func didSelect(suggestion: String) {
        persistentManager.didSearch(query: suggestion)
    }
}

enum SearchQueriesState {
    case ok, updating, error
}
