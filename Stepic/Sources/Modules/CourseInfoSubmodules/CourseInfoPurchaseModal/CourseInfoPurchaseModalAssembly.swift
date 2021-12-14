import UIKit

final class CourseInfoPurchaseModalAssembly: Assembly {
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
            coursesRepository: CoursesRepository.default,
            mobileTiersRepository: MobileTiersRepository.default,
            mobileTiersPersistenceService: MobileTiersPersistenceService(),
            wishlistRepository: WishlistRepository.default
        )
        let presenter = CourseInfoPurchaseModalPresenter(remoteConfig: .shared)
        let interactor = CourseInfoPurchaseModalInteractor(
            courseID: self.courseID,
            initialPromoCodeName: self.promoCodeName,
            initialMobileTierID: self.mobileTierID,
            presenter: presenter,
            provider: provider,
            iapService: IAPService.shared
        )
        let viewController = CourseInfoPurchaseModalViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
