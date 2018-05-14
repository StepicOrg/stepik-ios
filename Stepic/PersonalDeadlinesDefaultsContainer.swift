//
//  PersonalDeadlinesDefaultsContainer.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class PersonalDeadlinesDefaultsContainer {
    fileprivate let defaults = UserDefaults.standard

    fileprivate let declinedWidgetKey = "declinedWidget"

    private func key(for course: Int) -> String {
        return "\(declinedWidgetKey)_\(course)"
    }

    func declinedWidget(for course: Int) {
        defaults.set(true, forKey: key(for: course))
    }

    func canShowWidget(for course: Int) -> Bool {
        return (defaults.value(forKey: key(for: course)) as? Bool) != true
    }
}
