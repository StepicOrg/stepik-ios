//
//  StatsHelper.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class StatsHelper {
    private static let statsKey = "stats"
    private static let maxStreakKey = "max_streak"
    static let defaults = UserDefaults.standard
    
    private static let secondsInDay: TimeInterval = 24 * 60 * 60
    
    static var currentDayStreak: Int {
        get {
            var curDay = StatsHelper.dayByDate(Date())
            while curDay > 0 {
                if let todayXP = StatsHelper.loadStats()?[curDay], todayXP != 0 {
                    curDay -= 1
                } else {
                    break
                }
            }
            return StatsHelper.dayByDate(Date()) - curDay
        }
    }
    
    static func dayByDate(_ date: Date) -> Int {
        // Day num (01.01.1970 - 0, 02.01.1970 - 1, ...)
        let dayNum = Int(date.timeIntervalSince1970 / secondsInDay)
        return dayNum
    }
    
    static func dateByDay(_ day: Int) -> Date {
        // 00:00 am target day
        let date = Date(timeIntervalSince1970: secondsInDay * Double(day))
        return date
    }
    
    private static func stringDictToIntDict(_ dict: [String: String]) -> [Int: Int] {
        var intDict: [Int: Int] = [:]
        for (key, value) in dict {
            if let intKey = Int(key), let intVal = Int(value) {
                intDict[intKey] = intVal
            }
        }
        return intDict
    }
    
    private static func intDictToStringDict(_ dict: [Int: Int]) -> [String: String] {
        var stringDict: [String: String] = [:]
        for (key, value) in dict {
            stringDict[String(key)] = String(value)
        }
        return stringDict
    }
    
    static func loadStats() -> [Int: Int]? {
        guard let savedStats = defaults.value(forKey: statsKey) as? [String: String] else {
            return nil
        }
        
        return stringDictToIntDict(savedStats)
    }
    
    static func saveStats(_ value: [Int: Int]) {
        defaults.set(intDictToStringDict(value), forKey: statsKey)
    }
    
    static func getMaxStreak() -> Int {
        return defaults.value(forKey: maxStreakKey) as? Int ?? 1
    }
    
    static func updateMaxStreak(with value: Int) {
        defaults.set(max(getMaxStreak(), value), forKey: maxStreakKey)
    }
    
    static func incrementRating(_ value: Int, for date: Date = Date()) {
        var stats = loadStats()
        if stats == nil {
            stats = [:]
        }
        
        let day = dayByDate(date)
        if stats![day] == nil {
            stats![day] = value
        } else {
            stats![day]! += value
        }
        
        saveStats(stats!)
    }
}
