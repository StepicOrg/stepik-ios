import UIKit

protocol NewProfileAchievementsViewControllerProtocol: AnyObject {
    func displayAchievements(viewModel: NewProfileAchievements.AchievementsLoad.ViewModel)
    func displayAchievement(viewModel: NewProfileAchievements.AchievementPresentation.ViewModel)
}

final class NewProfileAchievementsViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: NewProfileAchievementsInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var newProfileAchievementsView: NewProfileAchievementsView? { self.view as? NewProfileAchievementsView }

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
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .tryAgain,
                action: { [weak self] in
                    self?.interactor.doAchievementsLoad(request: .init())
                }
            ),
            for: .connectionError
        )

        self.updateState(newState: self.state)
    }

    private func updateState(newState: NewProfileAchievements.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.isPlaceholderShown = false
            self.newProfileAchievementsView?.showLoading()
            return
        }

        if case .loading = self.state {
            self.isPlaceholderShown = false
            self.newProfileAchievementsView?.hideLoading()
        }

        switch newState {
        case .result(let viewModel):
            self.newProfileAchievementsView?.configure(viewModel: viewModel)
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .loading:
            break
        }
    }
}

extension NewProfileAchievementsViewController: NewProfileAchievementsViewControllerProtocol {
    func displayAchievements(viewModel: NewProfileAchievements.AchievementsLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayAchievement(viewModel: NewProfileAchievements.AchievementPresentation.ViewModel) {
        let alertManager = AchievementPopupAlertManager(source: .profile)
        let alert = alertManager.construct(with: viewModel.achievement, canShare: viewModel.isShareable)
        alertManager.present(alert: alert, inController: self)
    }
}

extension NewProfileAchievementsViewController: NewProfileAchievementsViewDelegate {
    func newProfileAchievementsView(
        _ view: NewProfileAchievementsView,
        didSelectAchievementWithUniqueIdentifier uniqueIdentifier: UniqueIdentifierType
    ) {
        self.interactor.doAchievementPresentation(request: .init(uniqueIdentifier: uniqueIdentifier))
    }
}
