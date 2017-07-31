//
//  AdaptiveStatsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol AdaptiveStatsView: class {

}

class AdaptiveStatsPresenter {
    weak var view: AdaptiveStatsView?
    
    var currentXP: Int = 0
    var currentLevel: Int = 0
    var currentWeekXP: Int = 0
    var bestStreak: Int = 0
    
    var last7DaysProgress: [Int] = []
    
    private var stats: [Int: Int]?
    
    typealias WeekProgress = (weekBegin: Date, progress: Int, isRecord: Bool)
    private(set) var progressByWeek: [WeekProgress] = []
    
    init(view: AdaptiveStatsView) {
        self.view = view
        
        loadStats()
    }
    
    fileprivate func loadStats() {
        currentXP = RatingHelper.retrieveRating()
        currentLevel = RatingHelper.getLevel(for: currentXP)
        bestStreak = StatsHelper.getMaxStreak()
        
        stats = StatsHelper.loadStats()
        guard let stats = stats else {
            return
        }
        
        let curDayNum = StatsHelper.dayByDate(Date())
        last7DaysProgress.removeAll()
        for i in 0..<7 {
            currentWeekXP += stats[curDayNum - i] ?? 0
            last7DaysProgress.append(stats[curDayNum - i] ?? 0)
        }
        
        // Calculate progress by week
        func getWeekBeginByDate(_ date: Date) -> Date {
            let calendar = Calendar(identifier: .gregorian)
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        }

        // Empty stats
        if stats.first == nil {
            return
        }
        
        var weekXP: [Int: Int] = [:]
        var weeks: Set<Date> = Set<Date>()
        var weekRecordBeginHash: Int? = nil
        for (day, progress) in stats {
            let weekBeginForCurrentDay = getWeekBeginByDate(StatsHelper.dateByDay(day))
            let weekHash = weekBeginForCurrentDay.hashValue
            weeks.insert(weekBeginForCurrentDay)
            
            if weekXP[weekHash] == nil {
                if weekRecordBeginHash == nil {
                    weekRecordBeginHash = weekHash
                }
                weekXP[weekHash] = progress
            } else {
                weekXP[weekHash]! += progress
            }
            
            if weekXP[weekRecordBeginHash!]! < weekXP[weekHash]! {
                weekRecordBeginHash = weekHash
            }
        }
        
        for firstDayOfWeek in weeks {
            progressByWeek.append((weekBegin: firstDayOfWeek, progress: weekXP[firstDayOfWeek.hashValue] ?? 0, isRecord: firstDayOfWeek.hashValue == weekRecordBeginHash && weeks.count > 1))
        }
        
        progressByWeek.reverse()
    }
    
}
