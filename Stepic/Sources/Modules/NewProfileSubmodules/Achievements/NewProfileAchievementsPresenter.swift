import UIKit

protocol NewProfileAchievementsPresenterProtocol {
    func presentAchievements(response: NewProfileAchievements.AchievementsLoad.Response)
}

final class NewProfileAchievementsPresenter: NewProfileAchievementsPresenterProtocol {
    weak var viewController: NewProfileAchievementsViewControllerProtocol?

    func presentAchievements(response: NewProfileAchievements.AchievementsLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeViewModel(achievementProgressesData: data)
            self.viewController?.displayAchievements(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayAchievements(viewModel: .init(state: .error))
        }
    }

    private func makeViewModel(
        achievementProgressesData: [AchievementProgressData]
    ) -> NewProfileAchievementsViewModel {
        let achievements = achievementProgressesData.compactMap { data -> AchievementViewData? in
            guard let kindDescription = AchievementKind(rawValue: data.kind) else {
                return nil
            }

            return AchievementViewData(
                id: kindDescription.rawValue,
                title: kindDescription.getName(),
                description: kindDescription.getDescription(for: data.maxScore),
                badge: kindDescription.getBadge(for: data.currentLevel),
                completedLevel: data.currentLevel,
                maxLevel: data.maxLevel,
                score: data.currentScore,
                maxScore: data.maxScore
            )
        }

        return NewProfileAchievementsViewModel(achievements: achievements)
    }
}
