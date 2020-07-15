import UIKit

protocol NewProfileAchievementsViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: NewProfileAchievements.SomeAction.ViewModel)
}

final class NewProfileAchievementsViewController: UIViewController {
    private let interactor: NewProfileAchievementsInteractorProtocol

    init(interactor: NewProfileAchievementsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileAchievementsView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewProfileAchievementsViewController: NewProfileAchievementsViewControllerProtocol {
    func displaySomeActionResult(viewModel: NewProfileAchievements.SomeAction.ViewModel) {}
}
