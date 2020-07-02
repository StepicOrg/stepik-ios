import UIKit

protocol NewProfileStreakNotificationsPresenterProtocol {
    func presentSomeActionResult(response: NewProfileStreakNotifications.SomeAction.Response)
}

final class NewProfileStreakNotificationsPresenter: NewProfileStreakNotificationsPresenterProtocol {
    weak var viewController: NewProfileStreakNotificationsViewControllerProtocol?

    func presentSomeActionResult(response: NewProfileStreakNotifications.SomeAction.Response) {}
}
