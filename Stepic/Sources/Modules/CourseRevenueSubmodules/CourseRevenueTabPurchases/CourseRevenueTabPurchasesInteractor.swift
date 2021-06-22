import Foundation
import PromiseKit

protocol CourseRevenueTabPurchasesInteractorProtocol {
    func doPurchasesLoad(request: CourseRevenueTabPurchases.PurchasesLoad.Request)
}

final class CourseRevenueTabPurchasesInteractor: CourseRevenueTabPurchasesInteractorProtocol {
    typealias PaginationState = (page: Int, hasNext: Bool)

    private let presenter: CourseRevenueTabPurchasesPresenterProtocol
    private let provider: CourseRevenueTabPurchasesProviderProtocol

    private var currentCourse: Course?
    private var currentCourseBenefits: [CourseBenefit]?

    private var paginationState = PaginationState(page: 1, hasNext: false)

    init(
        presenter: CourseRevenueTabPurchasesPresenterProtocol,
        provider: CourseRevenueTabPurchasesProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doPurchasesLoad(request: CourseRevenueTabPurchases.PurchasesLoad.Request) {
        guard let course = self.currentCourse else {
            return
        }

        self.provider.fetchCourseBenefits(courseID: course.id).done { fetchResult in
            self.currentCourseBenefits = fetchResult.value.0
            self.paginationState = PaginationState(page: 1, hasNext: fetchResult.value.1.hasNext)

            let data = CourseRevenueTabPurchases.PurchasesLoad.Data(
                courseBenefits: self.currentCourseBenefits ?? [],
                hasNextPage: self.paginationState.hasNext
            )
            self.presenter.presentPurchases(response: .init(result: .success(data)))
        }.catch { error in
            self.presenter.presentPurchases(response: .init(result: .failure(error)))
        }
    }

    enum Error: Swift.Error {
        case something
    }
}

extension CourseRevenueTabPurchasesInteractor: CourseRevenueTabPurchasesInputProtocol {
    func update(with course: Course) {
        self.currentCourse = course
        self.doPurchasesLoad(request: .init())
    }
}
