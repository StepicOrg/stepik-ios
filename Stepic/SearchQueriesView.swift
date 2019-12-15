//
//  SearchQueriesView.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol SearchQueriesView: AnyObject {
    func updateSuggestions(suggestions: [String])
    func setState(state: SearchQueriesState)
}
