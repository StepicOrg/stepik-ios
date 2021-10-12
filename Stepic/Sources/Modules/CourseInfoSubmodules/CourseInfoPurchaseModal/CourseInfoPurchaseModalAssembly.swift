import UIKit

final class CourseInfoPurchaseModalAssembly: Assembly {
    var moduleInput: CourseInfoPurchaseModalInputProtocol?

    private let courseID: Course.IdType

    private weak var moduleOutput: CourseInfoPurchaseModalOutputProtocol?

    init(courseID: Course.IdType, output: CourseInfoPurchaseModalOutputProtocol? = nil) {
        self.courseID = courseID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseInfoPurchaseModalProvider(
            courseID: self.courseID,
            coursesRepository: CoursesRepository.default
        )
        let presenter = CourseInfoPurchaseModalPresenter()
        let interactor = CourseInfoPurchaseModalInteractor(
            courseID: self.courseID,
            presenter: presenter,
            provider: provider
        )
        let viewController = CourseInfoPurchaseModalViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
