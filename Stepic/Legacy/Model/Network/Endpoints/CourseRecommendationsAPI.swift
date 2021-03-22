import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseRecommendationsAPI: APIEndpoint {
    override var name: String { "course-recommendations" }

    func getCourseRecommendations(
        languageString: String,
        platformString: String,
        page: Int
    ) -> Promise<([CourseRecommendation], Meta)> {
        let params: Parameters = [
            "language": languageString,
            "platform": platformString,
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
