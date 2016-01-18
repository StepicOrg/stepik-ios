//
//  TabsInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct TabsInfo {
    
    private static let allCoursesKey = "AllCoursesInfo"
    private static let myCoursesKey = "MyCoursesInfo"

    private static let defaults = NSUserDefaults.standardUserDefaults()
    
    static var allCoursesIds : [Int] {
        get {
            if let ids = defaults.objectForKey(allCoursesKey) as? [Int] {
                return ids
            } else {
                return []
            }
        }    
        set(value) {
            defaults.setObject(value, forKey: allCoursesKey)
            defaults.synchronize()
        }
    }
    
    static var myCoursesIds : [Int] {
        get {
            if let ids = defaults.objectForKey(myCoursesKey) as? [Int] {
                return ids
            } else {
                return []
            }
        }
        
        set(value) {
            defaults.setObject(value, forKey: myCoursesKey)
            defaults.synchronize()
        }
    }
}