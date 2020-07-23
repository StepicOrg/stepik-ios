import Foundation
import PromiseKit

protocol NewProfileAchievementsProviderProtocol {
    func fetchAchievements(
        breakCondition: @escaping AchievementsRepositoryProtocol.AchievementsBreakCondition
    ) -> Promise<[Achievement]>
    func fetchAchievementProgresses(
        userID: User.IdType,
        withBreakCondition breakCondition: @escaping AchievementsRepositoryProtocol.AchievementProgressesBreakCondition
    ) -> Promise<[AchievementProgress]>
    func fetchAchievementProgress(userID: User.IdType, kind: String) -> Promise<AchievementProgressData>
}

final class NewProfileAchievementsProvider: NewProfileAchievementsProviderProtocol {
    private let achievementsRepository: AchievementsRepositoryProtocol

    init(achievementsRepository: AchievementsRepositoryProtocol) {
        self.achievementsRepository = achievementsRepository
    }

    func fetchAchievements(
        breakCondition: @escaping AchievementsRepositoryProtocol.AchievementsBreakCondition
    ) -> Promise<[Achievement]> {
        self.achievementsRepository.fetchAllAchievements(breakCondition: breakCondition)
    }

    func fetchAchievementProgresses(
        userID: User.IdType,
        withBreakCondition breakCondition: @escaping AchievementsRepositoryProtocol.AchievementProgressesBreakCondition
    ) -> Promise<[AchievementProgress]> {
        self.achievementsRepository.fetchAllAchievementProgresses(userID: userID, withBreakCondition: breakCondition)
    }

    func fetchAchievementProgress(userID: User.IdType, kind: String) -> Promise<AchievementProgressData> {
        self.achievementsRepository.fetchAchievementProgress(userID: userID, kind: kind)
    }
}
