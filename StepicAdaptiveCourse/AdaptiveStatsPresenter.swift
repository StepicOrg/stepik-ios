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
    
    var recordsCount: Int {
        return 0
    }
    
    var currentXP: Int = 0
    var currentLevel: Int = 0
    var currentWeekXP: Int = 0
    var bestStreak: Int = 0
    
    var last7DaysProgress: [Int] = []
    
    private var stats: [Int: Int]?
    
    typealias WeekProgress = (weekBegin: Date, progress: Int)
    private var progressByWeek: [WeekProgress] = []
    
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
        
        var weekXP = 0
        var lastDayBegin: Date = getWeekBeginByDate(StatsHelper.dateByDay(stats.first!.key))
        for (day, progress) in stats {
            let weekBeginForCurrentDay = getWeekBeginByDate(StatsHelper.dateByDay(day))
            
            if lastDayBegin != weekBeginForCurrentDay {
                progressByWeek.append((weekBegin: lastDayBegin, progress: weekXP))
                lastDayBegin = weekBeginForCurrentDay
                weekXP = 0
            }
            
            weekXP += progress
        }
    }
    
}
