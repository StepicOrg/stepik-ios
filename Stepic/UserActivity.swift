//
//  UserActivity.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserActivity {
    var id: Int
    var pins: [Int]

    init(id: Int) {
        self.id = id
        self.pins = UserActivity.emptyYearPins
    }

    init(json: JSON) {
        self.id = json["id"].intValue
        self.pins = json["pins"].arrayValue.map({return $0.intValue})
    }

    var currentStreak: Int {
        var res = 0
        for (index, pin) in pins.enumerated() {
            if pin == 0 && index == 0 {
                continue
            }
            if pin == 0 {
                return res
            } else {
                res += 1
            }
        }
        return res
    }

    var longestStreak: Int {
        var cStreak = 0
        var lStreak = 0
        for pin in pins {
            if pin == 0 {
                if cStreak > lStreak {
                    lStreak = cStreak
                }
                cStreak = 0
            } else {
                cStreak += 1
            }
        }
        if cStreak > lStreak {
            lStreak = cStreak
        }

        return lStreak
    }

    var didSolveThisWeek: Bool {
        let thisWeekPins = pins.prefix(7)
        return thisWeekPins.index(where: { $0 > 0 }) != nil
    }

    var needsToSolveToday: Bool {
        guard pins.count > 1 else {
            return false
        }
        return pins[0] == 0 && pins[1] != 0
    }

    static var emptyYearPins: [Int] {
        return Array(repeating: 0, count: 365)
    }
}
