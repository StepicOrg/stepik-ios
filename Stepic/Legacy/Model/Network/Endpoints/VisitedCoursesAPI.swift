import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class VisitedCoursesAPI: APIEndpoint {
    override var name: String { "visited-courses" }

    func retrieve(page: Int = 1) -> Promise<([VisitedCourse], Meta)> {
        let params: Parameters = [
            "page": page
        ]

        return self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            params: params,
            withManager: self.manager
        )
    }
}
