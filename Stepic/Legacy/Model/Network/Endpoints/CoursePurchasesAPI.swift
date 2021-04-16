import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CoursePurchasesAPI: APIEndpoint {
    override var name: String { "course-purchases" }

    private let coursePurchasesPersistenceService: CoursePurchasesPersistenceServiceProtocol

    init(
        coursePurchasesPersistenceService: CoursePurchasesPersistenceServiceProtocol = CoursePurchasesPersistenceService()
    ) {
        self.coursePurchasesPersistenceService = coursePurchasesPersistenceService
        super.init()
    }

    func retrieve(courseID: Course.IdType) -> Promise<([CoursePurchase], Meta)> {
        Promise { seal in
            let params: Parameters = [
                CoursePurchase.JSONKey.course.rawValue: courseID
            ]

            firstly { () -> Guarantee<[CoursePurchase]> in
                self.coursePurchasesPersistenceService.fetch(courseID: courseID)
            }.then { cachedCoursePurchases -> Promise<([CoursePurchase], Meta, JSON)> in
                self.retrieve.request(
                    requestEndpoint: self.name,
                    paramName: self.name,
                    params: params,
                    updatingObjects: cachedCoursePurchases,
                    withManager: self.manager
                )
            }.done { coursePurchases, meta, _ in
                seal.fulfill((coursePurchases, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
