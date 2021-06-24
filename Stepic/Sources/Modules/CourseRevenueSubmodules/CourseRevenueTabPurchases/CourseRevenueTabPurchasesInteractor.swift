import Foundation
import PromiseKit

protocol CourseRevenueTabPurchasesInteractorProtocol {
    func doPurchasesLoad(request: CourseRevenueTabPurchases.PurchasesLoad.Request)
    func doNextPurchasesLoad(request: CourseRevenueTabPurchases.NextPurchasesLoad.Request)
    func doPurchasePresentation(request: CourseRevenueTabPurchases.PurchasePresentation.Request)
}

final class CourseRevenueTabPurchasesInteractor: CourseRevenueTabPurchasesInteractorProtocol {
    typealias PaginationState = (page: Int, hasNext: Bool)

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

    func doPurchasePresentation(request: CourseRevenueTabPurchases.PurchasePresentation.Request) {
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
    }
}

extension CourseRevenueTabPurchasesInteractor: CourseRevenueTabPurchasesInputProtocol {
    func update(with course: Course) {
        self.currentCourse = course
        self.doPurchasesLoad(request: .init())
    }
}
