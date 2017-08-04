//
//  SearchQueriesPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class SearchQueriesPresenter {
    weak var view : SearchQueriesView?
    var queriesAPI: QueriesAPI?
    
    init(queriesAPI: QueriesAPI) {
        self.queriesAPI = queriesAPI
    }
    
    func getSuggestions(query: String) {
        queriesAPI?.retrieve(query: query, success: {
            [weak self]
            suggestions in
            self?.view?.updateSuggestions(suggestions: suggestions)
        }, error: {
            [weak self]
            error in
            self?.view?.updateSuggestions(suggestions: [])
        })
    }
}
