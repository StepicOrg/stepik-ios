import Foundation
import PromiseKit

protocol CourseRevenueInteractorProtocol {
    func doCourseRevenueLoad(request: CourseRevenue.CourseRevenueLoad.Request)
    func doSubmodulesRegistration(request: CourseRevenue.SubmoduleRegistration.Request)
}

final class CourseRevenueInteractor: CourseRevenueInteractorProtocol {
    private let presenter: CourseRevenuePresenterProtocol
    private let provider: CourseRevenueProviderProtocol

    private let courseID: Course.IdType
    private var currentCourse: Course? {
        didSet {
            self.pushCurrentCourseToSubmodules(submodules: Array(self.submodules.values))
        }
    }

    // Tab index -> Submodule
    private var submodules: [Int: CourseRevenueSubmoduleProtocol] = [:]

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

    func doSubmodulesRegistration(request: CourseRevenue.SubmoduleRegistration.Request) {
        for (key, value) in request.submodules {
            self.submodules[key] = value
        }
        self.pushCurrentCourseToSubmodules(submodules: Array(self.submodules.values))
    }

    private func pushCurrentCourseToSubmodules(submodules: [CourseRevenueSubmoduleProtocol]) {
        if let course = self.currentCourse {
            submodules.forEach { $0.update(with: course) }
        }
    }

    enum Error: Swift.Error {
        case something
    }
}
