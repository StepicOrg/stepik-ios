//
//  TabsInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct TabsInfo {
    
    fileprivate static let allCoursesKey = "AllCoursesInfo"
    fileprivate static let myCoursesKey = "MyCoursesInfo"

    fileprivate static let defaults = UserDefaults.standard
    
    static var allCoursesIds : [Int] {
        get {
            if let ids = defaults.object(forKey: allCoursesKey) as? [Int] {
                return ids
            } else {
                return []
            }
        }    
        set(value) {
            defaults.set(value, forKey: allCoursesKey)
            defaults.synchronize()
        }
    }
    
    static var myCoursesIds : [Int] {
        get {
            if let ids = defaults.object(forKey: myCoursesKey) as? [Int] {
                return ids
            } else {
                return []
            }
        }
        
        set(value) {
            defaults.set(value, forKey: myCoursesKey)
            defaults.synchronize()
        }
    }
}
