import Foundation
import PromiseKit

protocol CoursePaymentsNetworkServiceProtocol: AnyObject {
    func fetch(courseID: Course.IdType) -> Promise<[CoursePayment]>
    func create(coursePayment: CoursePayment) -> Promise<CoursePayment>
}

final class CoursePaymentsNetworkService: CoursePaymentsNetworkServiceProtocol {
    private let coursePaymentsAPI: CoursePaymentsAPI

    init(coursePaymentsAPI: CoursePaymentsAPI) {
        self.coursePaymentsAPI = coursePaymentsAPI
    }

    func fetch(courseID: Course.IdType) -> Promise<[CoursePayment]> {
        Promise { seal in
            self.coursePaymentsAPI.retrieve(courseID: courseID).done { coursePayments, _ in
                seal.fulfill(coursePayments)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func create(coursePayment: CoursePayment) -> Promise<CoursePayment> {
        if coursePayment.data == nil || coursePayment.courseID == -1 {
            return Promise(error: Error.createFailed)
        }

        return Promise { seal in
            self.coursePaymentsAPI.create(coursePayment).done { coursePayment in
                seal.fulfill(coursePayment)
            }.catch { _ in
                seal.reject(Error.createFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case createFailed
    }
}
