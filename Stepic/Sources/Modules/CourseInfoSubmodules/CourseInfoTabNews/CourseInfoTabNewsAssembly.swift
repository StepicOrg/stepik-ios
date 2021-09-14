import UIKit

final class CourseInfoTabNewsAssembly: Assembly {
    var moduleInput: CourseInfoTabNewsInputProtocol?

    func makeModule() -> UIViewController {
        let provider = CourseInfoTabNewsProvider(announcementsRepository: AnnouncementsRepository.default)
        let presenter = CourseInfoTabNewsPresenter()
        let interactor = CourseInfoTabNewsInteractor(
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared
        )
        let viewController = CourseInfoTabNewsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
