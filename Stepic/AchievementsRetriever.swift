//
//  AchievementsRetriever.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 08.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import PromiseKit
import Foundation

class AchievementsRetriever {
    private var userId: Int

    private var achievementsAPI: AchievementsAPI
    private var achievementProgressesAPI: AchievementProgressesAPI

    init(userId: Int, achievementsAPI: AchievementsAPI, achievementProgressesAPI: AchievementProgressesAPI) {
        self.userId = userId
        self.achievementsAPI = achievementsAPI
        self.achievementProgressesAPI = achievementProgressesAPI
    }

    func loadAllAchievements(breakCondition: @escaping ([Achievement]) -> Bool) -> Promise<[Achievement]> {
        var allAchievements = [Achievement]()

        func load(page: Int) -> Promise<Bool> {
            return Promise { fulfill, _ in
                achievementsAPI.retrieve(page: page).then { (achievements, meta) -> Void in
                    allAchievements.append(contentsOf: achievements)
                    fulfill(meta.hasNext)
                }.catch { _ in
                    fulfill(false)
                }
            }
        }

        func collect(page: Int) -> Promise<[Achievement]> {
            return load(page: page).then { hasNext -> Promise<[Achievement]> in
                if !breakCondition(allAchievements) && hasNext {
                    return collect(page: page + 1)
                } else {
                    return Promise(value: allAchievements)
                }
            }
        }

        return collect(page: 1)
    }

    func loadAllAchievementProgresses(breakCondition: @escaping ([AchievementProgress]) -> Bool) -> Promise<[AchievementProgress]> {
        var allProgresses = [AchievementProgress]()

        func load(page: Int) -> Promise<Bool> {
            return Promise { fulfill, _ in
                achievementProgressesAPI.retrieve(user: userId, sortByObtainDateDesc: true, page: page).then { (progresses, meta) -> Void in
                    allProgresses.append(contentsOf: progresses)
                    fulfill(meta.hasNext)
                }.catch { _ in
                    fulfill(false)
                }
            }
        }

        func collect(page: Int) -> Promise<[AchievementProgress]> {
            return load(page: page).then { hasNext -> Promise<[AchievementProgress]> in
                if !breakCondition(allProgresses) && hasNext {
                    return collect(page: page + 1)
                } else {
                    return Promise(value: allProgresses)
                }
            }
        }

        return collect(page: 1)
    }

    func loadAchievementProgress(for achievement: Achievement) -> Promise<AchievementProgressData> {
        return loadAchievementProgress(for: achievement.kind)
    }

    func loadAchievementProgress(for kind: String) -> Promise<AchievementProgressData> {
        return Promise { fulfill, reject in
            let allAchievementsWithKind: Promise<[Achievement]> = Promise { fulfill, reject in
                achievementsAPI.retrieve(kind: kind).then { achievements, _ -> Void in
                    fulfill(achievements)
                }.catch { error in
                    reject(error)
                }
            }
            let allProgressesWithKind: Promise<[AchievementProgress]> = Promise { fulfill, reject in
                achievementProgressesAPI.retrieve(user: userId, kind: kind).then { progresses, _ -> Void in
                    fulfill(progresses)
                }.catch { error in
                    reject(error)
                }
            }

            when(fulfilled: allAchievementsWithKind, allProgressesWithKind).then { (achievements, progresses) -> Void in
                // achievement id -> target score
                var idToTargetScore = [Int: Int]()
                for achievement in achievements.sorted(by: { $0.targetScore < $1.targetScore }) {
                    idToTargetScore[achievement.id] = achievement.targetScore
                }

                var levelCount = 0
                let progressesSortedByMaxScore = progresses.sorted(by: { a, b in
                    let lhs = idToTargetScore[a.achievement] ?? 0
                    let rhs = idToTargetScore[b.achievement] ?? 0
                    return lhs < rhs
                })

                // Sort achievements by progress and find first non-obtained
                for progress in progressesSortedByMaxScore {
                    if progress.obtainDate == nil {
                        // Non-completed achievement, but have progress object
                        fulfill(AchievementProgressData(currentScore: progress.score,
                                                        maxScore: idToTargetScore[progress.achievement] ?? 0,
                                                        currentLevel: levelCount,
                                                        maxLevel: achievements.count,
                                                        kind: kind))
                        return
                    }
                    levelCount += 1
                }

                // No non-obtained achievements were found
                if let lastProgress = progressesSortedByMaxScore.last {
                    // Fulfilled achievement
                    fulfill(AchievementProgressData(currentScore: lastProgress.score,
                        maxScore: idToTargetScore[lastProgress.achievement] ?? 0,
                        currentLevel: achievements.count,
                        maxLevel: achievements.count,
                        kind: kind))
                } else {
                    let maxScoreForFirstLevel = achievements.sorted(by: { $0.targetScore < $1.targetScore }).first?.targetScore
                    // Non-completed achievement, empty progress
                    fulfill(AchievementProgressData(currentScore: 0,
                        maxScore: maxScoreForFirstLevel ?? 0,
                        currentLevel: 0,
                        maxLevel: achievements.count,
                        kind: kind))
                }
            }.catch { error in
                reject(error)
            }
        }
    }
}

struct AchievementProgressData {
    var currentScore: Int
    var maxScore: Int
    var currentLevel: Int
    var maxLevel: Int
    var kind: String
}
