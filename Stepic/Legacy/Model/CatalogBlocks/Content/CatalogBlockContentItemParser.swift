import Foundation
import SwiftyJSON

enum CatalogBlockContentItemParser {
    static func parse(json: JSON, kind: String) -> CatalogBlockContentItem? {
        guard let kind = CatalogBlockKind(rawValue: kind) else {
            return nil
        }

        switch kind {
        case .fullCourseLists:
            return FullCourseListsCatalogBlockContentItem(json: json)
        case .simpleCourseLists:
            return SimpleCourseListsCatalogBlockContentItem(json: json)
        case .authors:
            return AuthorsCatalogBlockContentItem(json: json)
        case .recommendedCourses:
            return nil
        case .specializations:
            return SpecializationsCatalogBlockContentItem(json: json)
        }
    }
}
