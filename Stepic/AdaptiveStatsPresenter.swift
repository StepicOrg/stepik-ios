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
    func setProgress(records: [WeekProgressViewData])
    func setGeneralStats(currentLevel: Int, bestStreak: Int, currentWeekXP: Int, last7DaysProgress: [Int]?)
}

struct WeekProgressViewData {
    let weekBegin: Date
    let progress: Int
    let isRecord: Bool
}

class AdaptiveStatsPresenter {
    weak var view: AdaptiveStatsView?

    fileprivate var ratingManager: AdaptiveRatingManager
    fileprivate var statsManager: AdaptiveStatsManager

    private var progressByWeek: [WeekProgressViewData]?

    init(statsManager: AdaptiveStatsManager, ratingManager: AdaptiveRatingManager, view: AdaptiveStatsView) {
        self.view = view

        self.statsManager = statsManager
        self.ratingManager = ratingManager
    }

    func reloadStats() {
        let currentXP = ratingManager.rating
        let currentLevel = AdaptiveRatingHelper.getLevel(for: currentXP)
        let bestStreak = max(1, statsManager.maxStreak)

        let last7DaysProgress = statsManager.getLastDays(count: 7)
        let currentWeekXP = last7DaysProgress.reduce(0, +)

        view?.setGeneralStats(currentLevel: currentLevel, bestStreak: bestStreak, currentWeekXP: currentWeekXP, last7DaysProgress: last7DaysProgress)
    }

    func reloadData(force: Bool = false) {
        if progressByWeek == nil || force {
            progressByWeek = []

            guard let stats = statsManager.stats else {
                view?.reload()
                return
            }

            // Calculate progress by week
            func getWeekBeginByDate(_ date: Date) -> Date {
                let calendar = Calendar(identifier: .gregorian)
                return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            }

            // Empty stats
            if stats.first == nil {
                view?.reload()
                return
            }

            var weekXP: [Int: Int] = [:]
            var weeks: Set<Date> = Set<Date>()
            var weekRecordBeginHash: Int?
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
                progressByWeek!.append(WeekProgressViewData(weekBegin: firstDayOfWeek, progress: weekXP[firstDayOfWeek.hashValue] ?? 0, isRecord: firstDayOfWeek.hashValue == weekRecordBeginHash && weeks.count > 1))
            }
        }

        view?.setProgress(records: progressByWeek!.reversed())
        view?.reload()
    }
}
