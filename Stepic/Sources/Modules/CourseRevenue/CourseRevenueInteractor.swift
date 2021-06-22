import Foundation
import PromiseKit

protocol CourseRevenueInteractorProtocol {
    func doCourseRevenueLoad(request: CourseRevenue.CourseRevenueLoad.Request)
}

final class CourseRevenueInteractor: CourseRevenueInteractorProtocol {
    private let presenter: CourseRevenuePresenterProtocol
    private let provider: CourseRevenueProviderProtocol

    private let courseID: Course.IdType
    private var currentCourse: Course?

    init(
        courseID: Course.IdType,
        presenter: CourseRevenuePresenterProtocol,
        provider: CourseRevenueProviderProtocol
    ) {
        self.courseID = courseID
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseRevenueLoad(request: CourseRevenue.CourseRevenueLoad.Request) {
        self.provider.fetchCourseAndBenefitSummary().done { fetchResult in
            self.currentCourse = fetchResult.value

            let benefitSummary = self.currentCourse?.courseBenefitSummaries.first(where: { $0.id == self.courseID })
            self.presenter.presentCourseRevenue(
                response: .init(result: .success(.init(courseBenefitSummary: benefitSummary)))
            )
        }.catch { error in
            print("CourseRevenueInteractor :: error = \(error)")
            self.presenter.presentCourseRevenue(response: .init(result: .failure(error)))
        }
    }

    enum Error: Swift.Error {
        case something
    }
}
