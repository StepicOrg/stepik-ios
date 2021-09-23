import UIKit

final class SubmissionsAssembly: Assembly {
    private let stepID: Step.IdType
    private let isTeacher: Bool
    private let submissionsFilterQuery: SubmissionsFilterQuery?
    private let isSelectionEnabled: Bool
    private let navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState

    private weak var moduleOutput: SubmissionsOutputProtocol?

    init(
        stepID: Step.IdType,
        isTeacher: Bool,
        submissionsFilterQuery: SubmissionsFilterQuery? = nil,
        isSelectionEnabled: Bool = false,
        navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init(),
        output: SubmissionsOutputProtocol? = nil
    ) {
        self.stepID = stepID
        self.isTeacher = isTeacher
        self.submissionsFilterQuery = submissionsFilterQuery
        self.isSelectionEnabled = isSelectionEnabled
        self.navigationBarAppearance = navigationBarAppearance
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = SubmissionsProvider(
            submissionsNetworkService: SubmissionsNetworkService(submissionsAPI: SubmissionsAPI()),
            attemptsNetworkService: AttemptsNetworkService(attemptsAPI: AttemptsAPI()),
            reviewSessionsNetworkService: ReviewSessionsNetworkService(reviewSessionsAPI: ReviewSessionsAPI()),
            instructionsNetworkService: InstructionsNetworkService(instructionsAPI: InstructionsAPI()),
            usersNetworkService: UsersNetworkService(usersAPI: UsersAPI()),
            usersPersistenceService: UsersPersistenceService(),
            userAccountService: UserAccountService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            stepsPersistenceService: StepsPersistenceService()
        )
        let presenter = SubmissionsPresenter(urlFactory: StepikURLFactory())
        let interactor = SubmissionsInteractor(
            stepID: self.stepID,
            isTeacher: self.isTeacher,
            submissionsFilterQuery: self.submissionsFilterQuery,
            isSelectionEnabled: self.isSelectionEnabled,
            presenter: presenter,
            provider: provider
        )
        let viewController = SubmissionsViewController(
            interactor: interactor,
            isSelectionEnabled: self.isSelectionEnabled,
            initialIsSubmissionsFilterAvailable: self.isTeacher,
            appearance: .init(navigationBarAppearance: self.navigationBarAppearance)
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
