//
//  StatsManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class StatsManager {
    static let shared = StatsManager()
    
    private let statsKey = "stats"
    private let maxStreakKey = "max_streak"
    let defaults = UserDefaults.standard
    
    private let secondsInDay: TimeInterval = 24 * 60 * 60
    
    var stats: [Int: Int]? {
        get {
            guard let savedStats = defaults.value(forKey: statsKey) as? [String: String] else {
                return nil
            }
            
            return stringDictToIntDict(savedStats)
        }
        set(newValue) {
            defaults.set(newValue == nil ? nil : intDictToStringDict(newValue!), forKey: statsKey)
        }
    }
    
    var maxStreak: Int {
        get {
            return defaults.value(forKey: maxStreakKey) as? Int ?? 1
        }
        set(newValue) {
            defaults.set(max(maxStreak, newValue), forKey: maxStreakKey)
        }
    }
    
    var currentDayStreak: Int {
        get {
            let _stats = stats
            var curDay = dayByDate(Date())
            while curDay > 0 {
                if let todayXP = _stats?[curDay], todayXP != 0 {
                    curDay -= 1
                } else {
                    break
                }
            }
            
            return dayByDate(Date()) - curDay
        }
    }
    
    func dayByDate(_ date: Date) -> Int {
        // Day num (01.01.1970 - 0, 02.01.1970 - 1, ...)
        let dayNum = Int(date.timeIntervalSince1970 / secondsInDay)
        return dayNum
    }
    
    func dateByDay(_ day: Int) -> Date {
        // 00:00 am target day
        let date = Date(timeIntervalSince1970: secondsInDay * Double(day))
        return date
    }
    
    private func stringDictToIntDict(_ dict: [String: String]) -> [Int: Int] {
        var intDict: [Int: Int] = [:]
        for (key, value) in dict {
            if let intKey = Int(key), let intVal = Int(value) {
                intDict[intKey] = intVal
            }
        }
        return intDict
    }
    
    private func intDictToStringDict(_ dict: [Int: Int]) -> [String: String] {
        var stringDict: [String: String] = [:]
        for (key, value) in dict {
            stringDict[String(key)] = String(value)
        }
        return stringDict
    }
    
    func incrementRating(_ value: Int, for date: Date = Date()) {
        var _stats = stats
        if _stats == nil {
            _stats = [:]
        }
        
        let day = dayByDate(date)
        if _stats![day] == nil {
            _stats![day] = value
        } else {
            _stats![day]! += value
        }
        
        stats = _stats
    }
    
    func getLastDays(count: Int) -> [Int] {
        let _stats = stats
        
        let curDayNum = dayByDate(Date())
        var lastDaysProgress: [Int] = []
        for i in 0..<count {
            lastDaysProgress.append(_stats?[curDayNum - i] ?? 0)
        }
        
        return lastDaysProgress
    }
}
