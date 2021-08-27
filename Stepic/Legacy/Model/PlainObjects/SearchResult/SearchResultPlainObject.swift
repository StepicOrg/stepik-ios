import Foundation
import SwiftyJSON

struct SearchResultPlainObject {
    let score: Float
    let courseID: Int?
    let lessonID: Int?
    let stepID: Int?
    let commentID: Int?
}

extension SearchResultPlainObject {
    init(json: JSON) {
        self.score = json[JSONKey.score.rawValue].floatValue
        self.courseID = json[JSONKey.course.rawValue].int
        self.lessonID = json[JSONKey.lesson.rawValue].int
        self.stepID = json[JSONKey.step.rawValue].int
        self.commentID = json[JSONKey.comment.rawValue].int
    }

    enum JSONKey: String {
        case score
        case course
        case lesson
        case step
        case comment
    }
}
