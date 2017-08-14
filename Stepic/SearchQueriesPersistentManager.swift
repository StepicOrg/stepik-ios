//
//  SearchQueriesPersistentManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 06.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class SearchQueriesPersistentManager {
    private let key = "searchqueries"
    private let defaults = UserDefaults.standard

    func didSearch(query: String) {
        var queries = defaults.value(forKey: key) as? [String: Int] ?? [String: Int]()
        if let count = queries[query] {
            queries[query] = count + 1
        } else {
            queries[query] = 1
        }
        defaults.set(queries, forKey: key)
        defaults.synchronize()
    }

    func getTop(for query: String, count: Int) -> [String] {
        guard let queriesDict = defaults.value(forKey: key) as? [String: Int] else {
            return []
        }

        let arr = [String](queriesDict.filter({
            key, _ in
            key.indexOf(query.lowercased()) != nil
        }).sorted(by: {
            (first: (key: String, value: Int), second: (key: String, value: Int))  in
            if first.value == second.value {
                return first.key.characters.count < second.key.characters.count
            } else {
                return first.value > second.value
            }
        }).map({
            key, _ in
            key
        }).prefix(count))

        return arr
    }
}
