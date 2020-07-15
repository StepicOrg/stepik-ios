import UIKit

protocol NewProfileAchievementsPresenterProtocol {
    func presentSomeActionResult(response: NewProfileAchievements.SomeAction.Response)
}

final class NewProfileAchievementsPresenter: NewProfileAchievementsPresenterProtocol {
    weak var viewController: NewProfileAchievementsViewControllerProtocol?

    func presentSomeActionResult(response: NewProfileAchievements.SomeAction.Response) {}
}
