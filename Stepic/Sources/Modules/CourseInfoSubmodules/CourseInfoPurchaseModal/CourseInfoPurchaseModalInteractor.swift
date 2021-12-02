import Foundation
import PromiseKit

protocol CourseInfoPurchaseModalInteractorProtocol {
    func doModalLoad(request: CourseInfoPurchaseModal.ModalLoad.Request)
}

final class CourseInfoPurchaseModalInteractor: CourseInfoPurchaseModalInteractorProtocol {
    weak var moduleOutput: CourseInfoPurchaseModalOutputProtocol?

    private let presenter: CourseInfoPurchaseModalPresenterProtocol
    private let provider: CourseInfoPurchaseModalProviderProtocol

    private let iapService: IAPServiceProtocol

    private let courseID: Course.IdType
    private let initialPromoCodeName: String?
    private let initialMobileTierID: MobileTier.IdType?

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
                self.currentMobileTier = mobileTier

                let data = CourseInfoPurchaseModal.ModalLoad.Response.Data(
                    course: course,
                    mobileTier: mobileTier
                )

                self.presenter.presentModal(response: .init(result: .success(data)))
            }
            .catch { error in
                self.presenter.presentModal(response: .init(result: .failure(error)))
            }
    }

    // MARK: Private API

    private func fetchInitialMobileTier() -> Promise<MobileTierPlainObject> {
        if let initialMobileTierID = self.initialMobileTierID {
            return self.provider
                .fetchMobileTierFromCache(mobileTierID: initialMobileTierID)
                .then { mobileTier -> Promise<MobileTierPlainObject> in
                    if let mobileTier = mobileTier {
                        let isLocalizedPricesEmpty = (mobileTier.priceTierDisplayPrice?.isEmpty ?? true)
                            && (mobileTier.promoTierDisplayPrice?.isEmpty ?? true)
                        if isLocalizedPricesEmpty {
                            return self.iapService.getLocalizedPrices(mobileTier: mobileTier).then {
                                priceTierLocalizedPrice, promoTierLocalizedPrice -> Promise<MobileTierPlainObject> in
                                mobileTier.priceTierDisplayPrice = priceTierLocalizedPrice
                                mobileTier.promoTierDisplayPrice = promoTierLocalizedPrice
                                return .value(mobileTier.plainObject)
                            }
                        } else {
                            return .value(mobileTier.plainObject)
                        }
                    } else {
                        return self.fetchMobileTier(promoCodeName: self.initialPromoCodeName)
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
            .then { mobileTier -> Guarantee<(MobileTierPlainObject, String?, String?)> in
                self.iapService
                    .getLocalizedPrices(mobileTier: mobileTier)
                    .map { (mobileTier, $0.price, $0.promo) }
            }
            .then { mobileTier, priceTierLocalizedPrice, promoTierLocalizedPrice -> Promise<MobileTierPlainObject> in
                var mutableMobileTier = mobileTier
                mutableMobileTier.priceTierDisplayPrice = priceTierLocalizedPrice
                mutableMobileTier.promoTierDisplayPrice = promoTierLocalizedPrice

                return .value(mutableMobileTier)
            }
    }
}

extension CourseInfoPurchaseModalInteractor: CourseInfoPurchaseModalInputProtocol {}
