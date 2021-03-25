import Foundation
import PromiseKit

protocol CourseRecommendationsNetworkServiceProtocol: AnyObject {
    func fetch(language: ContentLanguage, platform: PlatformType, page: Int) -> Promise<([CourseRecommendation], Meta)>
}

extension CourseRecommendationsNetworkServiceProtocol {
    func fetch(language: ContentLanguage, platform: PlatformType) -> Promise<([CourseRecommendation], Meta)> {
        self.fetch(language: language, platform: platform, page: 1)
    }
}

final class CourseRecommendationsNetworkService: CourseRecommendationsNetworkServiceProtocol {
    private let courseRecommendationsAPI: CourseRecommendationsAPI

    init(courseRecommendationsAPI: CourseRecommendationsAPI) {
        self.courseRecommendationsAPI = courseRecommendationsAPI
    }

    func fetch(
        language: ContentLanguage,
        platform: PlatformType,
        page: Int
    ) -> Promise<([CourseRecommendation], Meta)> {
        self.courseRecommendationsAPI.getCourseRecommendations(
            languageString: language.languageString,
            platformString: platform.stringValue,
            page: page
        )
    }
}
