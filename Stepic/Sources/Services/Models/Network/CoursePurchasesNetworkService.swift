import Foundation
import PromiseKit

protocol CoursePurchasesNetworkServiceProtocol: AnyObject {
    func fetch(courseID: Course.IdType) -> Promise<[CoursePurchase]>
}

final class CoursePurchasesNetworkService: CoursePurchasesNetworkServiceProtocol {
    private let coursePurchasesAPI: CoursePurchasesAPI

    init(coursePurchasesAPI: CoursePurchasesAPI) {
        self.coursePurchasesAPI = coursePurchasesAPI
    }

    func fetch(courseID: Course.IdType) -> Promise<[CoursePurchase]> {
        Promise { seal in
            self.coursePurchasesAPI.retrieve(courseID: courseID).done { coursePurchases, _ in
                seal.fulfill(coursePurchases)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
