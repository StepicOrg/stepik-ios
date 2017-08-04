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
    weak var view : SearchQueriesView?
    var queriesAPI: QueriesAPI?
    
    var currentRequest: Request?
    
    init(queriesAPI: QueriesAPI) {
        self.queriesAPI = queriesAPI
    }
    
    func getSuggestions(query: String) {
        let localSuggestions = [query]
        self.view?.updateSuggestions(suggestions: localSuggestions)
        currentRequest?.cancel()
        self.view?.setState(state: .updating)
        currentRequest = queriesAPI?.retrieve(query: query, success: {
            [weak self]
            suggestions in
            self?.view?.updateSuggestions(suggestions: localSuggestions + suggestions)
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
}

enum SearchQueriesState {
    case ok, updating, error
}
