import Foundation
import PromiseKit

protocol CourseInfoPurchaseModalInteractorProtocol {
    func doModalLoad(request: CourseInfoPurchaseModal.ModalLoad.Request)
    func doCheckPromoCode(request: CourseInfoPurchaseModal.CheckPromoCode.Request)
    func doPromoCodeDidChange(request: CourseInfoPurchaseModal.PromoCodeDidChange.Request)
    func doWishlistMainAction(request: CourseInfoPurchaseModal.WishlistMainAction.Request)
    func doStartLearningPresentation(request: CourseInfoPurchaseModal.StartLearningPresentation.Request)
    func doPurchaseCourse(request: CourseInfoPurchaseModal.PurchaseCourse.Request)
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
            self.currentMobileTier?.promoCodeName = request.promoCode
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

    func doPurchaseCourse(request: CourseInfoPurchaseModal.PurchaseCourse.Request) {
        guard let currentCourse = self.currentCourse,
              let currentMobileTier = self.currentMobileTier else {
            return print(
                """
                CourseInfoPurchaseModalInteractor :: buy course error = some data is `nil`, \
                currentCourse = \(String(describing: self.currentCourse)), \
                currentMobileTier = \(String(describing: self.currentMobileTier))
                """
            )
        }

        guard currentMobileTier.priceTier != nil,
              let purchaseMobileTier = currentMobileTier.promoTier ?? currentMobileTier.priceTier,
              self.iapService.canBuyCourse(currentCourse, mobileTier: purchaseMobileTier) else {
            print("CourseInfoPurchaseModalInteractor :: buy course error = can't buy course")
            return self.presenter.presentPurchaseCourseResult(
                response: .init(
                    state: .error(
                        error: IAPService.Error.unsupportedCourse,
                        modalData: .init(course: currentCourse, mobileTier: currentMobileTier)
                    )
                )
            )
        }

        let promoCode = currentMobileTier.promoTier != nil ? currentMobileTier.promoCodeName : nil

        print(
            """
            CourseInfoPurchaseModalInteractor :: starting buy course = \(self.courseID), \
            mobileTier = \(purchaseMobileTier), promoCode = \(String(describing: promoCode))
            """
        )

        self.presenter.presentPurchaseCourseResult(response: .init(state: .inProgress))

        self.iapService
            .buy(courseID: self.courseID, mobileTier: purchaseMobileTier, promoCode: promoCode, delegate: self)
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

                    let shouldFetchPriceTierDisplayPrice = mobileTier.priceTier != nil
                        && (mobileTier.priceTierDisplayPrice?.isEmpty ?? true)
                    let shouldFetchPromoTierDisplayPrice = mobileTier.promoTier != nil
                        && (mobileTier.promoTierDisplayPrice?.isEmpty ?? true)

                    if shouldFetchPriceTierDisplayPrice || shouldFetchPromoTierDisplayPrice {
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

// MARK: - CourseInfoPurchaseModalInteractor: IAPServiceDelegate -

extension CourseInfoPurchaseModalInteractor: IAPServiceDelegate {
    func iapService(_ service: IAPServiceProtocol, didPurchaseCourse courseID: Course.IdType) {
        print("CourseInfoPurchaseModalInteractor :: \(#function), courseID = \(courseID)")
        self.presenter.presentPurchaseCourseResult(response: .init(state: .success))
        self.moduleOutput?.handleCourseInfoPurchaseModalDidPurchaseCourse(courseID: courseID)
    }

    func iapService(
        _ service: IAPServiceProtocol,
        didFailPurchaseCourse courseID: Course.IdType,
        withError error: Swift.Error
    ) {
        print("CourseInfoPurchaseModalInteractor :: \(#function), courseID = \(courseID), error = \(error)")

        guard let currentCourse = self.currentCourse,
              let currentMobileTier = self.currentMobileTier,
              let iapServiceError = error as? IAPService.Error else {
            return
        }

        let modalData = CourseInfoPurchaseModal.ModalData(course: currentCourse, mobileTier: currentMobileTier)
        self.presenter
            .presentPurchaseCourseResult(response: .init(state: .error(error: iapServiceError, modalData: modalData)))
    }
}

extension CourseInfoPurchaseModalInteractor: CourseInfoPurchaseModalInputProtocol {}
