import UIKit

final class SubmissionsFilterAssembly: Assembly {
    private let presentationDescription: SubmissionsFilter.PresentationDescription

    private weak var moduleOutput: SubmissionsFilterOutputProtocol?

    init(
        presentationDescription: SubmissionsFilter.PresentationDescription = .init(
            availableFilters: .default,
            prefilledFilters: []
        ),
        output: SubmissionsFilterOutputProtocol? = nil
    ) {
        self.presentationDescription = presentationDescription
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let presenter = SubmissionsFilterPresenter()
        let interactor = SubmissionsFilterInteractor(
            presenter: presenter,
            presentationDescription: self.presentationDescription
        )
        let viewController = SubmissionsFilterViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
