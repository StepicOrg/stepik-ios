import UIKit

protocol NewProfileStreakNotificationsViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: NewProfileStreakNotifications.SomeAction.ViewModel)
}

final class NewProfileStreakNotificationsViewController: UIViewController {
    private let interactor: NewProfileStreakNotificationsInteractorProtocol

    init(interactor: NewProfileStreakNotificationsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileStreakNotificationsView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewProfileStreakNotificationsViewController: NewProfileStreakNotificationsViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewProfileStreakNotifications.SomeAction.ViewModel) {}
}
