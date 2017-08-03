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
    
    func loadStats() -> [Int: Int]? {
        guard let savedStats = defaults.value(forKey: statsKey) as? [String: String] else {
            return nil
        }
        
        return stringDictToIntDict(savedStats)
    }
    
    func saveStats(_ value: [Int: Int]) {
        defaults.set(intDictToStringDict(value), forKey: statsKey)
    }
    
    func getMaxStreak() -> Int {
        return defaults.value(forKey: maxStreakKey) as? Int ?? 1
    }
    
    func updateMaxStreak(with value: Int) {
        defaults.set(max(getMaxStreak(), value), forKey: maxStreakKey)
    }
    
    func incrementRating(_ value: Int, for date: Date = Date()) {
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
