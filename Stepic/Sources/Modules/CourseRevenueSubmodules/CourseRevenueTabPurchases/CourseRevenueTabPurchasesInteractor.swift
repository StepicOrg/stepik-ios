import Foundation
import PromiseKit

protocol CourseRevenueTabPurchasesInteractorProtocol {
    func doPurchasesLoad(request: CourseRevenueTabPurchases.PurchasesLoad.Request)
    func doNextPurchasesLoad(request: CourseRevenueTabPurchases.NextPurchasesLoad.Request)
    func doPurchaseDetailsPresentation(request: CourseRevenueTabPurchases.PurchaseDetailsPresentation.Request)
    func doCourseInfoPresentation(request: CourseRevenueTabPurchases.CourseInfoPresentation.Request)
    func doProfilePresentation(request: CourseRevenueTabPurchases.ProfilePresentation.Request)
    func doBuyerProfilePresentation(request: CourseRevenueTabPurchases.BuyerProfilePresentation.Request)
}

final class CourseRevenueTabPurchasesInteractor: CourseRevenueTabPurchasesInteractorProtocol {
    weak var moduleOutput: CourseRevenueTabPurchasesOutputProtocol?

    private let presenter: CourseRevenueTabPurchasesPresenterProtocol
    private let provider: CourseRevenueTabPurchasesProviderProtocol

    private let analytics: Analytics

    private var currentCourse: Course?
    private var currentCourseBenefits: [CourseBenefit]?

    private var paginationState = PaginationState(page: 1, hasNext: false)

    init(
        presenter: CourseRevenueTabPurchasesPresenterProtocol,
        provider: CourseRevenueTabPurchasesProviderProtocol,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
    }

    func doPurchasesLoad(request: CourseRevenueTabPurchases.PurchasesLoad.Request) {
        guard let currentCourse = self.currentCourse else {
            return
        }

        self.provider.fetchCourseBenefits(courseID: currentCourse.id).done { fetchResult in
            let isFallbackCacheEmpty = fetchResult.source == .cache && fetchResult.value.0.isEmpty
            if isFallbackCacheEmpty {
                return self.presenter.presentPurchases(response: .init(result: .failure(Error.fetchFailed)))
            }

            self.currentCourseBenefits = fetchResult.value.0
            self.paginationState = PaginationState(page: 1, hasNext: fetchResult.value.1.hasNext)

            fetchResult.value.0.forEach { $0.course = currentCourse }
            CoreDataHelper.shared.save()

            let data = CourseRevenueTabPurchases.PurchasesData(
                courseBenefits: fetchResult.value.0,
                hasNextPage: fetchResult.value.1.hasNext
            )
            self.presenter.presentPurchases(response: .init(result: .success(data)))
        }.catch { error in
            self.presenter.presentPurchases(response: .init(result: .failure(error)))
        }
    }

    func doNextPurchasesLoad(request: CourseRevenueTabPurchases.NextPurchasesLoad.Request) {
        guard let currentCourse = self.currentCourse else {
            return
        }

        let nextPageIndex = self.paginationState.page + 1

        self.provider.fetchRemoteCourseBenefits(
            courseID: currentCourse.id,
            page: nextPageIndex
        ).done { courseBenefits, meta in
            self.currentCourseBenefits?.append(contentsOf: courseBenefits)
            self.paginationState = PaginationState(page: nextPageIndex, hasNext: meta.hasNext)

            courseBenefits.forEach { $0.course = currentCourse }
            CoreDataHelper.shared.save()

            let data = CourseRevenueTabPurchases.PurchasesData(
                courseBenefits: courseBenefits,
                hasNextPage: meta.hasNext
            )
            self.presenter.presentNextPurchases(response: .init(result: .success(data)))
        }.catch { error in
            self.presenter.presentNextPurchases(response: .init(result: .failure(error)))
        }
    }

    func doPurchaseDetailsPresentation(request: CourseRevenueTabPurchases.PurchaseDetailsPresentation.Request) {
        guard let currentCourse = self.currentCourse,
              let targetCourseBenefit = self.currentCourseBenefits?.first(
                where: { "\($0.id)" == request.viewModelUniqueIdentifier }
              ) else {
            return
        }

        self.analytics.send(
            .courseBenefitClicked(
                benefitID: targetCourseBenefit.id,
                status: targetCourseBenefit.statusString,
                courseID: currentCourse.id,
                courseTitle: currentCourse.title
            )
        )

        self.presenter.presentPurchaseDetails(response: .init(courseBenefitID: targetCourseBenefit.id))
    }

    func doCourseInfoPresentation(request: CourseRevenueTabPurchases.CourseInfoPresentation.Request) {
        self.moduleOutput?.handleCourseRevenueTabPurchasesDidRequestPresentCourseInfo(courseID: request.courseID)
    }

    func doProfilePresentation(request: CourseRevenueTabPurchases.ProfilePresentation.Request) {
        self.moduleOutput?.handleCourseRevenueTabPurchasesDidRequestPresentUser(userID: request.userID)
    }

    func doBuyerProfilePresentation(request: CourseRevenueTabPurchases.BuyerProfilePresentation.Request) {
        guard let targetCourseBenefit = self.currentCourseBenefits?.first(
            where: { "\($0.id)" == request.viewModelUniqueIdentifier }
        ), let buyerID = targetCourseBenefit.buyerID else {
            return
        }

        self.moduleOutput?.handleCourseRevenueTabPurchasesDidRequestPresentUser(userID: buyerID)
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseRevenueTabPurchasesInteractor: CourseRevenueTabPurchasesInputProtocol {
    func update(with course: Course) {
        self.currentCourse = course

        self.presenter.presentLoadingState(response: .init())
        self.doPurchasesLoad(request: .init())
    }
}
