import Foundation
import PromiseKit

protocol CourseRevenueTabMonthlyInteractorProtocol {
    func doCourseBenefitByMonthsLoad(request: CourseRevenueTabMonthly.CourseBenefitByMonthsLoad.Request)
    func doNextCourseBenefitByMonthsLoad(request: CourseRevenueTabMonthly.NextCourseBenefitByMonthsLoad.Request)
}

final class CourseRevenueTabMonthlyInteractor: CourseRevenueTabMonthlyInteractorProtocol {
    weak var moduleOutput: CourseRevenueTabMonthlyOutputProtocol?

    private let presenter: CourseRevenueTabMonthlyPresenterProtocol
    private let provider: CourseRevenueTabMonthlyProviderProtocol

    private var currentCourse: Course?
    private var currentCourseBenefitByMonths: [CourseBenefitByMonth]?

    private var paginationState = PaginationState()

    init(
        presenter: CourseRevenueTabMonthlyPresenterProtocol,
        provider: CourseRevenueTabMonthlyProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseBenefitByMonthsLoad(request: CourseRevenueTabMonthly.CourseBenefitByMonthsLoad.Request) {
        guard let currentCourse = self.currentCourse else {
            return
        }

        self.provider.fetchCourseBenefitByMonths(courseID: currentCourse.id).done { fetchResult in
            let isFallbackCacheEmpty = fetchResult.source == .cache && fetchResult.value.0.isEmpty
            if isFallbackCacheEmpty {
                return self.presenter.presentCourseBenefitByMonths(response: .init(result: .failure(Error.fetchFailed)))
            }

            self.currentCourseBenefitByMonths = fetchResult.value.0
            self.paginationState = PaginationState(page: 1, hasNext: fetchResult.value.1.hasNext)

            fetchResult.value.0.forEach { $0.course = currentCourse }
            CoreDataHelper.shared.save()

            let data = CourseRevenueTabMonthly.CourseBenefitByMonthsData(
                courseBenefitByMonths: fetchResult.value.0,
                hasNextPage: fetchResult.value.1.hasNext
            )
            self.presenter.presentCourseBenefitByMonths(response: .init(result: .success(data)))
        }.catch { error in
            self.presenter.presentCourseBenefitByMonths(response: .init(result: .failure(error)))
        }
    }

    func doNextCourseBenefitByMonthsLoad(request: CourseRevenueTabMonthly.NextCourseBenefitByMonthsLoad.Request) {
        guard let currentCourse = self.currentCourse else {
            return
        }

        let nextPageIndex = self.paginationState.page + 1

        self.provider.fetchRemoteCourseBenefitByMonths(
            courseID: currentCourse.id,
            page: nextPageIndex
        ).done { courseBenefitByMonths, meta in
            self.currentCourseBenefitByMonths?.append(contentsOf: courseBenefitByMonths)
            self.paginationState = PaginationState(page: nextPageIndex, hasNext: meta.hasNext)

            courseBenefitByMonths.forEach { $0.course = currentCourse }
            CoreDataHelper.shared.save()

            let data = CourseRevenueTabMonthly.CourseBenefitByMonthsData(
                courseBenefitByMonths: courseBenefitByMonths,
                hasNextPage: meta.hasNext
            )
            self.presenter.presentNextCourseBenefitByMonths(response: .init(result: .success(data)))
        }.catch { error in
            self.presenter.presentNextCourseBenefitByMonths(response: .init(result: .failure(error)))
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseRevenueTabMonthlyInteractor: CourseRevenueTabMonthlyInputProtocol {
    func update(with course: Course) {
        self.currentCourse = course

        self.presenter.presentLoadingState(response: .init())
        self.doCourseBenefitByMonthsLoad(request: .init())
    }
}
