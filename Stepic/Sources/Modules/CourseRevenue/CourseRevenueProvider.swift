import Foundation
import PromiseKit

protocol CourseRevenueProviderProtocol {}

final class CourseRevenueProvider: CourseRevenueProviderProtocol {
    private let courseID: Course.IdType

    init(courseID: Course.IdType) {
        self.courseID = courseID
    }
}
