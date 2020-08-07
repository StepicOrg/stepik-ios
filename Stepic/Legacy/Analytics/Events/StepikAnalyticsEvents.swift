import Foundation

extension AnalyticsEvent {
    static func catalogDisplay(
        courseID: Course.IdType,
        viewSource: CourseViewSource,
        contentLanguage: ContentLanguage = ContentLanguageService().globalContentLanguage
    ) -> StepikAnalyticsEvent {
        let dataParams = self.makeCourseCardDataParameters(
            courseID: courseID,
            viewSource: viewSource,
            contentLanguage: contentLanguage
        )

        let name = "catalog-display"

        let params: [String: Any] = [
            "data": dataParams,
            "name": name,
            "timestamp": Date().timeIntervalSince1970
        ]

        return StepikAnalyticsEvent(name: name, parameters: params)
    }

    static func catalogClick(
        courseID: Course.IdType,
        viewSource: CourseViewSource,
        contentLanguage: ContentLanguage = ContentLanguageService().globalContentLanguage
    ) -> StepikAnalyticsEvent {
        let dataParams = self.makeCourseCardDataParameters(
            courseID: courseID,
            viewSource: viewSource,
            contentLanguage: contentLanguage
        )

        let name = "catalog-click"

        let params: [String: Any] = [
            "data": dataParams,
            "name": name,
            "timestamp": Date().timeIntervalSince1970
        ]

        return StepikAnalyticsEvent(name: name, parameters: params)
    }

    private static func makeCourseCardDataParameters(
        courseID: Course.IdType,
        viewSource: CourseViewSource,
        contentLanguage: ContentLanguage
    ) -> JSONDictionary {
        var params: JSONDictionary = [
            "course": courseID,
            "platform": "ios",
            "source": viewSource.name,
            "position": 1,
            "language": contentLanguage.languageString
        ]

        if let viewSourceParams = viewSource.params {
            params["data"] = viewSourceParams
        }

        return params
    }
}
