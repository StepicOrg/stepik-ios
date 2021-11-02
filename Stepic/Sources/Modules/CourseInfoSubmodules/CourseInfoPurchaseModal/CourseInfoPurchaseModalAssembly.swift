import UIKit

final class CourseInfoPurchaseModalAssembly: Assembly {
    var moduleInput: CourseInfoPurchaseModalInputProtocol?

    private let courseID: Course.IdType
    private let promoCodeName: String?
    private let mobileTierID: MobileTier.IdType?

    private weak var moduleOutput: CourseInfoPurchaseModalOutputProtocol?

    init(
        courseID: Course.IdType,
        promoCodeName: String?,
        mobileTierID: MobileTier.IdType?,
        output: CourseInfoPurchaseModalOutputProtocol? = nil
    ) {
        self.courseID = courseID
        self.promoCodeName = promoCodeName
        self.mobileTierID = mobileTierID
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
            initialPromoCodeName: self.promoCodeName,
            mobileTierID: self.mobileTierID,
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
