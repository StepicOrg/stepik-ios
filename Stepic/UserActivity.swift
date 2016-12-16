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
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.pins = json["pins"].arrayValue.map({return $0.intValue})
    }
    
    var currentStreak : Int {
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
    
    var longestStreak : Int {
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
            print("pin: \(pin), current: \(cStreak), longest: \(lStreak)") 
        }
        if cStreak > lStreak {
            lStreak = cStreak
        }
        
        return lStreak
    }
}
