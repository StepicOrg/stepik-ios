import Foundation
import PromiseKit

protocol LessonFinishedDemoPanModalInteractorProtocol {
    func doModalLoad(request: LessonFinishedDemoPanModal.ModalLoad.Request)
    func doModalMainAction(request: LessonFinishedDemoPanModal.MainModalAction.Request)
}

final class LessonFinishedDemoPanModalInteractor: LessonFinishedDemoPanModalInteractorProtocol {
    weak var moduleOutput: LessonFinishedDemoPanModalOutputProtocol?

    private let sectionID: Section.IdType
    private let promoCodeName: String?

    private let presenter: LessonFinishedDemoPanModalPresenterProtocol
    private let provider: LessonFinishedDemoPanModalProviderProtocol

    private let iapService: IAPServiceProtocol
    private let remoteConfig: RemoteConfig

    private let analytics: Analytics

    private var currentCourse: Course?
    private var currentMobileTier: MobileTierPlainObject?

    private var shouldCheckIAPPurchaseSupport: Bool {
        (self.currentCourse?.isPaid ?? false) && self.remoteConfig.coursePurchaseFlow == .iap
    }
    private var isSupportedIAPPurchase: Bool {
        self.shouldCheckIAPPurchaseSupport && self.currentMobileTier?.priceTier != nil
    }

    init(
        presenter: LessonFinishedDemoPanModalPresenterProtocol,
        provider: LessonFinishedDemoPanModalProviderProtocol,
        sectionID: Section.IdType,
        promoCodeName: String?,
        iapService: IAPServiceProtocol,
        remoteConfig: RemoteConfig,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
        self.sectionID = sectionID
        self.promoCodeName = promoCodeName
        self.iapService = iapService
        self.remoteConfig = remoteConfig
        self.analytics = analytics
    }

    func doModalLoad(request: LessonFinishedDemoPanModal.ModalLoad.Request) {
        self.provider
            .fetchSection(id: self.sectionID)
            .compactMap { $0 }
            .then { section -> Promise<(Section, Course)> in
                if let course = section.course {
                    return .value((section, course))
                } else {
                    return self.provider
                        .fetchCourse(id: section.courseId)
                        .compactMap { $0 }
                        .then { course -> Promise<(Section, Course)> in
                            section.course = course
                            return .value((section, course))
                        }
                }
            }
            .then { section, course -> Promise<(Section, Course)> in
                self.fetchDisplayPrice(course: course).map { (section, $0) }
            }
            .done { section, course in
                self.currentCourse = course

                let data = LessonFinishedDemoPanModal.ModalData(
                    course: course,
                    section: section,
                    coursePurchaseFlow: self.remoteConfig.coursePurchaseFlow,
                    mobileTier: self.currentMobileTier,
                    shouldCheckIAPPurchaseSupport: self.shouldCheckIAPPurchaseSupport,
                    isSupportedIAPPurchase: self.isSupportedIAPPurchase
                )
                self.presenter.presentModal(response: .init(result: .success(data)))
            }
            .catch { error in
                print("LessonFinishedDemoPanModalInteractor :: failed load data with error = \(error)")
                self.presenter.presentModal(response: .init(result: .failure(error)))
            }
    }

    func doModalMainAction(request: LessonFinishedDemoPanModal.MainModalAction.Request) {
        if let currentCourse = self.currentCourse {
            self.analytics.send(
                .courseBuyPressed(
                    id: currentCourse.id,
                    source: .demoLessonDialog,
                    isWishlisted: currentCourse.isInWishlist,
                    promoCode: self.promoCodeName
                )
            )
        }

        self.moduleOutput?.handleLessonFinishedDemoPanModalMainAction()
    }

    // MARK: Private API

    private func fetchDisplayPrice(course: Course) -> Promise<Course> {
        switch self.remoteConfig.coursePurchaseFlow {
        case .web:
            if course.isPaid && self.iapService.canBuyCourse(course) && (course.displayPriceIAP?.isEmpty ?? true) {
                return self.iapService.fetchLocalizedPrice(for: course).then { localizedPrice -> Promise<Course> in
                    course.displayPriceIAP = localizedPrice
                    return .value(course)
                }
            }
            return .value(course)
        case .iap:
            return self.provider
                .fetchMobileTier(courseID: course.id, promoCodeName: self.promoCodeName)
                .compactMap { $0 }
                .then { self.iapService.fetchAndSetLocalizedPrices(mobileTier: $0) }
                .then { mobileTier -> Promise<Course> in
                    self.currentMobileTier = mobileTier
                    self.currentMobileTier?.promoCodeName = self.promoCodeName
                    return .value(course)
                }
        }
    }
}
