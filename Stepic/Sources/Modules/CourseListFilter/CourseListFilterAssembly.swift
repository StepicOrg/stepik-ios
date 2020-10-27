import UIKit

final class CourseListFilterAssembly: Assembly {
    private let presentationDescription: CourseListFilter.PresentationDescription

    private weak var moduleOutput: CourseListFilterOutputProtocol?

    init(
        presentationDescription: CourseListFilter.PresentationDescription = .init(
            availableFilters: .allOptions,
            prefilledFilters: []
        ),
        output: CourseListFilterOutputProtocol? = nil
    ) {
        self.presentationDescription = presentationDescription
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let presenter = CourseListFilterPresenter()
        let interactor = CourseListFilterInteractor(
            presenter: presenter,
            presentationDescription: self.presentationDescription,
            contentLanguageService: ContentLanguageService()
        )
        let viewController = CourseListFilterViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
