//
//  CourseListsCache.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CourseListsCache {

    private func getKey(forLanguage language: ContentLanguage) -> String {
        return "ListIds_\(language.languageString)"
    }

    func set(ids: [Int], forLanguage language: ContentLanguage) {
        UserDefaults.standard.setValue(ids, forKey: getKey(forLanguage: language))
    }

    func get(forLanguage language: ContentLanguage) -> [Int] {
        return UserDefaults.standard.value(forKey: getKey(forLanguage: language)) as? [Int] ?? []
    }
}
