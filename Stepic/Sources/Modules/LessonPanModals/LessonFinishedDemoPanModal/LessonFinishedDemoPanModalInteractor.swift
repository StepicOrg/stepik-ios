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

    private var currentMobileTier: MobileTier?

    init(
        presenter: LessonFinishedDemoPanModalPresenterProtocol,
        provider: LessonFinishedDemoPanModalProviderProtocol,
        sectionID: Section.IdType,
        promoCodeName: String?,
        iapService: IAPServiceProtocol,
        remoteConfig: RemoteConfig
    ) {
        self.presenter = presenter
        self.provider = provider
        self.sectionID = sectionID
        self.promoCodeName = promoCodeName
        self.iapService = iapService
        self.remoteConfig = remoteConfig
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
            .then { section, course -> Guarantee<(Section, Course)> in
                self.fetchDisplayPrice(course: course).map { (section, $0) }
            }
            .done { section, course in
                CoreDataHelper.shared.save()

                self.presenter.presentModal(
                    response: .init(
                        course: course,
                        section: section,
                        coursePurchaseFlow: self.remoteConfig.coursePurchaseFlow,
                        mobileTier: self.currentMobileTier
                    )
                )
            }
            .catch { error in
                print("LessonFinishedDemoPanModalInteractor :: failed load data with error = \(error)")
            }
    }

    func doModalMainAction(request: LessonFinishedDemoPanModal.MainModalAction.Request) {
        self.moduleOutput?.handleLessonFinishedDemoPanModalMainAction()
    }

    // MARK: Private API

    private func fetchDisplayPrice(course: Course) -> Guarantee<Course> {
        switch self.remoteConfig.coursePurchaseFlow {
        case .web:
            if course.isPaid && self.iapService.canBuyCourse(course) && (course.displayPriceIAP?.isEmpty ?? true) {
                return self.iapService.getLocalizedPrice(for: course).then { localizedPrice in
                    course.displayPriceIAP = localizedPrice
                    return .value(course)
                }
            }
        case .iap:
            return Guarantee { seal in
                self.provider
                    .calculateMobileTier(courseID: course.id, promoCodeName: self.promoCodeName)
                    .compactMap { $0 }
                    .compactMap { mobileTier in
                        course.mobileTiers.first(where: { $0.id == mobileTier.id })
                    }
                    .then { mobileTier -> Guarantee<(MobileTier, String?, String?)> in
                        self.iapService
                            .getLocalizedPrices(mobileTier: mobileTier)
                            .map { (mobileTier, $0.price, $0.promo) }
                    }
                    .done { mobileTier, priceTierLocalizedPrice, promoTierLocalizedPrice in
                        mobileTier.priceTierDisplayPrice = priceTierLocalizedPrice
                        mobileTier.promoTierDisplayPrice = promoTierLocalizedPrice
                        self.currentMobileTier = mobileTier

                        seal(course)
                    }
                    .catch { _ in
                        seal(course)
                    }
            }
        }
        return .value(course)
    }
}
