//
//  PersonalDeadlinesDefaultsContainer.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class PersonalDeadlinesDefaultsContainer {

    enum WidgetAction {
        case declined, accepted

        var key: String {
            switch self {
            case .declined:
                return "declinedWidget"
            case .accepted:
                return "acceptedWidget"
            }
        }

        func key(for course: Int) -> String {
            return "\(key)_\(course)"
        }
    }

    fileprivate let defaults = UserDefaults.standard

    func declinedWidget(for course: Int) {
        defaults.set(true, forKey: WidgetAction.declined.key(for: course))
    }

    func acceptedWidget(for course: Int) {
        defaults.set(true, forKey: WidgetAction.accepted.key(for: course))
    }

    func canShowWidget(for course: Int) -> Bool {
        return (defaults.value(forKey: WidgetAction.declined.key(for: course)) as? Bool) != true && (defaults.value(forKey: WidgetAction.accepted.key(for: course)) as? Bool) != true
    }
}
