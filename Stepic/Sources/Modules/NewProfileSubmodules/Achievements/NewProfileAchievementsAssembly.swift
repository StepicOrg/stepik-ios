import UIKit

final class NewProfileAchievementsAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let achievementsRepository = AchievementsRepository(
            achievementsNetworkService: AchievementsNetworkService(achievementsAPI: AchievementsAPI()),
            achievementProgressesNetworkService: AchievementProgressesNetworkService(
                achievementProgressesAPI: AchievementProgressesAPI()
            )
        )
        let provider = NewProfileAchievementsProvider(achievementsRepository: achievementsRepository)
        let presenter = NewProfileAchievementsPresenter()
        let interactor = NewProfileAchievementsInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileAchievementsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
