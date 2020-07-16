import UIKit

protocol NewProfileAchievementsViewControllerProtocol: AnyObject {
    func displayAchievements(viewModel: NewProfileAchievements.AchievementsLoad.ViewModel)
}

final class NewProfileAchievementsViewController: UIViewController {
    private let interactor: NewProfileAchievementsInteractorProtocol

    private var state: NewProfileAchievements.ViewControllerState

    init(
        interactor: NewProfileAchievementsInteractorProtocol,
        initialState: NewProfileAchievements.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
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
    func displayAchievements(viewModel: NewProfileAchievements.AchievementsLoad.ViewModel) {}
}
