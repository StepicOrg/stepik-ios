//
//  AdaptiveStatsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol AdaptiveStatsView: class {
    func reload()
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
    
    typealias AchievementRecord = (name: String, info: String, type: AchievementType, cover: UIImage?, isUnlocked: Bool, currentProgress: Int, maxProgress: Int)
    private(set) var achievements: [AchievementRecord] = []
    
    fileprivate var ratingManager: RatingManager?
    fileprivate var statsManager: StatsManager?
    fileprivate var achievementsManager: AchievementManager?
    
    init(statsManager: StatsManager, ratingManager: RatingManager, achievementsManager: AchievementManager, view: AdaptiveStatsView) {
        self.view = view
        
        self.statsManager = statsManager
        self.ratingManager = ratingManager
        self.achievementsManager = achievementsManager
    }
    
    func reloadStats() {
        achievements.removeAll()
        progressByWeek.removeAll()
        
        currentXP = ratingManager?.retrieveRating() ?? 0
        currentLevel = RatingHelper.getLevel(for: currentXP)
        bestStreak = statsManager?.getMaxStreak() ?? 1
        
        stats = statsManager?.loadStats()
        guard let stats = stats, let statsManager = statsManager else {
            return
        }
        
        let curDayNum = statsManager.dayByDate(Date())
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
            let weekBeginForCurrentDay = getWeekBeginByDate(statsManager.dateByDay(day))
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
        
        // Achievements
        achievementsManager?.storedAchievements.forEach({ achievement in
            achievements.append((name: achievement.name, info: achievement.info ?? "", type: achievement.type, cover: achievement.cover ?? nil, isUnlocked: achievement.isUnlocked, currentProgress: achievement.progressValue, maxProgress: achievement.maxProgressValue))
        })
        
        view?.reload()
    }
    
}
