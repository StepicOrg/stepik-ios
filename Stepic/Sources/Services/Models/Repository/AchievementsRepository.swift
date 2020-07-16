import Foundation
import PromiseKit

protocol AchievementsRepositoryProtocol: AnyObject {
    typealias AchievementsBreakCondition = ([Achievement]) -> Bool
    typealias AchievementProgressesBreakCondition = ([AchievementProgress]) -> Bool

    func fetchAllAchievements(breakCondition: @escaping AchievementsBreakCondition) -> Promise<[Achievement]>
    func fetchAllAchievementProgresses(
        userID: User.IdType,
        withBreakCondition breakCondition: @escaping AchievementProgressesBreakCondition
    ) -> Promise<[AchievementProgress]>
    func fetchAchievementProgress(userID: User.IdType, kind: String) -> Promise<AchievementProgressData>
}

extension AchievementsRepositoryProtocol {
    func fetchAllAchievements() -> Promise<[Achievement]> {
        self.fetchAllAchievements(breakCondition: { _ in false })
    }

    func fetchAllAchievementProgresses(userID: User.IdType) -> Promise<[AchievementProgress]> {
        self.fetchAllAchievementProgresses(userID: userID, withBreakCondition: { _ in false })
    }

    func fetchAchievementProgress(userID: User.IdType, achievement: Achievement) -> Promise<AchievementProgressData> {
        self.fetchAchievementProgress(userID: userID, kind: achievement.kind)
    }
}

final class AchievementsRepository: AchievementsRepositoryProtocol {
    private let achievementsNetworkService: AchievementsNetworkServiceProtocol
    private let achievementProgressesNetworkService: AchievementProgressesNetworkServiceProtocol

    init(
        achievementsNetworkService: AchievementsNetworkServiceProtocol,
        achievementProgressesNetworkService: AchievementProgressesNetworkServiceProtocol
    ) {
        self.achievementsNetworkService = achievementsNetworkService
        self.achievementProgressesNetworkService = achievementProgressesNetworkService
    }

    func fetchAllAchievements(breakCondition: @escaping AchievementsBreakCondition) -> Promise<[Achievement]> {
        var allAchievements = [Achievement]()

        func load(page: Int) -> Guarantee<Bool> {
            Guarantee { seal in
                self.achievementsNetworkService.fetch(page: page).done { (achievements, meta) in
                    allAchievements.append(contentsOf: achievements)
                    seal(meta.hasNext)
                }.catch { _ in
                    seal(false)
                }
            }
        }

        func collect(page: Int) -> Promise<[Achievement]> {
            load(page: page).then { hasNext -> Promise<[Achievement]> in
                if !breakCondition(allAchievements) && hasNext {
                    return collect(page: page + 1)
                } else {
                    return .value(allAchievements)
                }
            }
        }

        return collect(page: 1)
    }

    func fetchAllAchievementProgresses(
        userID: User.IdType,
        withBreakCondition breakCondition: @escaping AchievementProgressesBreakCondition
    ) -> Promise<[AchievementProgress]> {
        var allProgresses = [AchievementProgress]()

        func load(page: Int) -> Guarantee<Bool> {
            Guarantee { seal in
                self.achievementProgressesNetworkService.fetchWithSortingByObtainDateDesc(
                    userID: userID,
                    kind: nil,
                    page: page
                ).done { (progresses, meta) in
                    allProgresses.append(contentsOf: progresses)
                    seal(meta.hasNext)
                }.catch { _ in
                    seal(false)
                }
            }
        }

        func collect(page: Int) -> Promise<[AchievementProgress]> {
            load(page: page).then { hasNext -> Promise<[AchievementProgress]> in
                if !breakCondition(allProgresses) && hasNext {
                    return collect(page: page + 1)
                } else {
                    return .value(allProgresses)
                }
            }
        }

        return collect(page: 1)
    }

    func fetchAchievementProgress(userID: User.IdType, kind: String) -> Promise<AchievementProgressData> {
        Promise { seal in
            let allAchievementsWithKind: Promise<[Achievement]> = Promise { seal in
                self.achievementsNetworkService.fetch(kind: kind, page: 1).done { achievements, _ in
                    seal.fulfill(achievements)
                }.catch { error in
                    seal.reject(error)
                }
            }
            let allProgressesWithKind: Promise<[AchievementProgress]> = Promise { seal in
                self.achievementProgressesNetworkService.fetch(userID: userID, kind: kind, page: 1).done {
                    progresses, _ in
                    seal.fulfill(progresses)
                }.catch { error in
                    seal.reject(error)
                }
            }

            when(fulfilled: allAchievementsWithKind, allProgressesWithKind).done { (achievements, progresses) in
                // achievement id -> target score
                var idToTargetScore = [Achievement.IdType: Int]()
                for achievement in achievements.sorted(by: { $0.targetScore < $1.targetScore }) {
                    idToTargetScore[achievement.id] = achievement.targetScore
                }

                var levelCount = 0
                let progressesSortedByMaxScore = progresses.sorted { lhs, rhs in
                    let lhsScore = idToTargetScore[lhs.achievement] ?? 0
                    let rhsScore = idToTargetScore[rhs.achievement] ?? 0
                    return lhsScore < rhsScore
                }

                // Sort achievements by progress and find first non-obtained
                for progress in progressesSortedByMaxScore {
                    if progress.obtainDate == nil {
                        // Non-completed achievement, but have progress object
                        seal.fulfill(
                            AchievementProgressData(
                                currentScore: progress.score,
                                maxScore: idToTargetScore[progress.achievement] ?? 0,
                                currentLevel: levelCount,
                                maxLevel: achievements.count,
                                kind: kind
                            )
                        )
                        return
                    }
                    levelCount += 1
                }

                // No non-obtained achievements were found
                if let lastProgress = progressesSortedByMaxScore.last {
                    // Fulfilled achievement
                    seal.fulfill(
                        AchievementProgressData(
                            currentScore: lastProgress.score,
                            maxScore: idToTargetScore[lastProgress.achievement] ?? 0,
                            currentLevel: achievements.count,
                            maxLevel: achievements.count,
                            kind: kind
                        )
                    )
                } else {
                    let maxScoreForFirstLevel = achievements
                        .sorted(by: { $0.targetScore < $1.targetScore })
                        .first?
                        .targetScore
                    // Non-completed achievement, empty progress
                    seal.fulfill(
                        AchievementProgressData(
                            currentScore: 0,
                            maxScore: maxScoreForFirstLevel ?? 0,
                            currentLevel: 0,
                            maxLevel: achievements.count,
                            kind: kind
                        )
                    )
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
