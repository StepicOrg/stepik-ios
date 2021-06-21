import Foundation
import PromiseKit

protocol CourseRevenueInteractorProtocol {
    func doCourseRevenueLoad(request: CourseRevenue.CourseRevenueLoad.Request)
}

final class CourseRevenueInteractor: CourseRevenueInteractorProtocol {
    private let presenter: CourseRevenuePresenterProtocol
    private let provider: CourseRevenueProviderProtocol

    private let courseID: Course.IdType

    init(
        courseID: Course.IdType,
        presenter: CourseRevenuePresenterProtocol,
        provider: CourseRevenueProviderProtocol
    ) {
        self.courseID = courseID
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseRevenueLoad(request: CourseRevenue.CourseRevenueLoad.Request) {}

    enum Error: Swift.Error {
        case something
    }
}
