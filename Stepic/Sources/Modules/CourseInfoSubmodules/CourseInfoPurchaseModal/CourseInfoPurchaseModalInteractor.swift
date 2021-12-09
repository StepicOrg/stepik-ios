import Foundation
import PromiseKit

protocol CourseInfoPurchaseModalInteractorProtocol {
    func doModalLoad(request: CourseInfoPurchaseModal.ModalLoad.Request)
    func doCheckPromoCode(request: CourseInfoPurchaseModal.CheckPromoCode.Request)
    func doPromoCodeDidChange(request: CourseInfoPurchaseModal.PromoCodeDidChange.Request)
    func doWishlistMainAction(request: CourseInfoPurchaseModal.WishlistMainAction.Request)
    func doStartLearningPresentation(request: CourseInfoPurchaseModal.StartLearningPresentation.Request)
}

final class CourseInfoPurchaseModalInteractor: CourseInfoPurchaseModalInteractorProtocol {
    weak var moduleOutput: CourseInfoPurchaseModalOutputProtocol?

    private let presenter: CourseInfoPurchaseModalPresenterProtocol
    private let provider: CourseInfoPurchaseModalProviderProtocol

    private let iapService: IAPServiceProtocol

    private let courseID: Course.IdType
    private let initialPromoCodeName: String?
    private let initialMobileTierID: MobileTier.IdType?
    private var initialMobileTier: MobileTierPlainObject?

    private var currentCourse: Course?
    private var currentPromoCodeName: String?
    private var currentMobileTier: MobileTierPlainObject?

    init(
        courseID: Course.IdType,
        initialPromoCodeName: String?,
        initialMobileTierID: MobileTier.IdType?,
        presenter: CourseInfoPurchaseModalPresenterProtocol,
        provider: CourseInfoPurchaseModalProviderProtocol,
        iapService: IAPServiceProtocol
    ) {
        self.courseID = courseID
        self.initialPromoCodeName = initialPromoCodeName
        self.initialMobileTierID = initialMobileTierID
        self.presenter = presenter
        self.provider = provider
        self.iapService = iapService

        self.currentPromoCodeName = initialPromoCodeName
    }

    func doModalLoad(request: CourseInfoPurchaseModal.ModalLoad.Request) {
        self.provider
            .fetchCourse()
            .compactMap { $0 }
            .then { course -> Promise<(Course, MobileTierPlainObject)> in
                self.fetchInitialMobileTier().map { (course, $0) }
            }
            .done { course, mobileTier in
                self.currentCourse = course

                var resultMobileTier = mobileTier
                resultMobileTier.promoCodeName = self.initialPromoCodeName
                self.initialMobileTier = resultMobileTier
                self.currentMobileTier = resultMobileTier

                let data = CourseInfoPurchaseModal.ModalData(
                    course: course,
                    mobileTier: resultMobileTier
                )

                self.presenter.presentModal(response: .init(result: .success(data)))
            }
            .catch { error in
                self.presenter.presentModal(response: .init(result: .failure(error)))
            }
    }

    func doCheckPromoCode(request: CourseInfoPurchaseModal.CheckPromoCode.Request) {
        self.fetchMobileTier(promoCodeName: request.promoCode).done { mobileTier in
            self.currentMobileTier = mobileTier
            self.currentPromoCodeName = request.promoCode

            let data = CourseInfoPurchaseModal.ModalData(
                course: self.currentCourse.require(),
                mobileTier: mobileTier
            )

            self.presenter.presentCheckPromoCodeResult(response: .init(result: .success(data)))
        }.catch { error in
            self.presenter.presentCheckPromoCodeResult(response: .init(result: .failure(error)))
        }
    }

    func doPromoCodeDidChange(request: CourseInfoPurchaseModal.PromoCodeDidChange.Request) {
        guard self.currentPromoCodeName != request.promoCode else {
            return
        }

        defer {
            self.currentPromoCodeName = request.promoCode
        }

        guard let currentMobileTier = self.currentMobileTier,
              let initialMobileTier = self.initialMobileTier else {
            return
        }

        if currentMobileTier.promoTier != nil {
            let resultMobileTier = MobileTierPlainObject(
                id: initialMobileTier.id,
                courseID: initialMobileTier.courseID,
                priceTier: initialMobileTier.priceTier,
                promoTier: nil,
                priceTierDisplayPrice: initialMobileTier.priceTierDisplayPrice,
                promoTierDisplayPrice: nil,
                promoCodeName: request.promoCode
            )
            self.currentMobileTier = resultMobileTier

            let data = CourseInfoPurchaseModal.ModalData(
                course: self.currentCourse.require(),
                mobileTier: resultMobileTier
            )

            self.presenter.presentModal(response: .init(result: .success(data)))
        }
    }

    func doWishlistMainAction(request: CourseInfoPurchaseModal.WishlistMainAction.Request) {
        guard let currentCourse = self.currentCourse,
              !currentCourse.isInWishlist else {
            return
        }

        self.presenter.presentAddCourseToWishlistResult(response: .init(state: .loading))

        self.provider.addCourseToWishlist().done {
            self.presenter.presentAddCourseToWishlistResult(response: .init(state: .success))
            self.moduleOutput?.handleCourseInfoPurchaseModalDidAddCourseToWishlist(courseID: self.courseID)
        }.catch { _ in
            self.presenter.presentAddCourseToWishlistResult(response: .init(state: .error))
        }
    }

    func doStartLearningPresentation(request: CourseInfoPurchaseModal.StartLearningPresentation.Request) {
        self.moduleOutput?.handleCourseInfoPurchaseModalDidRequestStartLearning(courseID: self.courseID)
    }

    // MARK: Private API

    private func fetchInitialMobileTier() -> Promise<MobileTierPlainObject> {
        if let initialMobileTierID = self.initialMobileTierID {
            return self.provider
                .fetchMobileTierFromCache(mobileTierID: initialMobileTierID)
                .then { mobileTier -> Promise<MobileTierPlainObject> in
                    guard let mobileTier = mobileTier,
                          mobileTier.isIDPromoCodeNameEqual(self.initialPromoCodeName) else {
                        return self.fetchMobileTier(promoCodeName: self.initialPromoCodeName)
                    }

                    if mobileTier.isDisplayTiersEmpty {
                        return self.iapService.fetchAndSetLocalizedPrices(mobileTier: mobileTier).map(\.plainObject)
                    } else {
                        return .value(mobileTier.plainObject)
                    }
                }
        } else {
            return self.fetchMobileTier(promoCodeName: self.initialPromoCodeName)
        }
    }

    private func fetchMobileTier(promoCodeName: String?) -> Promise<MobileTierPlainObject> {
        self.provider
            .calculateMobileTier(promoCodeName: promoCodeName)
            .compactMap { $0 }
            .then { self.iapService.fetchAndSetLocalizedPrices(mobileTier: $0) }
            .then { mobileTier -> Promise<MobileTierPlainObject> in
                var result = mobileTier
                result.promoCodeName = promoCodeName
                return .value(result)
            }
    }
}

extension CourseInfoPurchaseModalInteractor: CourseInfoPurchaseModalInputProtocol {}
