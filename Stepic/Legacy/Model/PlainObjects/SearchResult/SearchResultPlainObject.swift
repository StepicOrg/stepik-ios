import Foundation
import SwiftyJSON

struct SearchResultPlainObject {
    let id: Int
    let position: Int
    let score: Float

    let targetID: Int
    let targetTypeString: String

    let courseID: Int?
    let courseOwnerID: Int?
    let courseAuthorsIDs: [Int]?
    let courseTitle: String?
    let courseCoverURL: String?

    let lessonID: Int?
    let lessonOwnerID: Int?
    let lessonTitle: String?
    let lessonCoverURL: String?

    let stepID: Int?
    let stepPosition: Int?
    var stepDiscussionProxyID: String?

    let commentID: Int?
    let commentParentID: Int?
    let commentUserID: Int?
    let commentText: String?
    var commentUserInfo: UserInfo?

    var targetType: SearchResultTargetType? { SearchResultTargetType(rawValue: self.targetTypeString) }

    var isCourse: Bool {
        self.targetType == .course && self.courseID != nil
    }

    var isLesson: Bool {
        self.targetType == .lesson && self.lessonID != nil
    }

    var isStep: Bool {
        self.targetType == .step && self.stepID != nil
    }

    var isComment: Bool {
        self.targetType == .comment && self.commentID != nil
    }
}

extension SearchResultPlainObject {
    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.position = json[JSONKey.position.rawValue].intValue
        self.score = json[JSONKey.score.rawValue].floatValue
        self.targetID = json[JSONKey.targetID.rawValue].intValue
        self.targetTypeString = json[JSONKey.targetType.rawValue].stringValue
        self.courseID = json[JSONKey.course.rawValue].int
        self.courseOwnerID = json[JSONKey.courseOwner.rawValue].int
        self.courseAuthorsIDs = json[JSONKey.courseAuthors.rawValue].array?.compactMap(\.int)
        self.courseTitle = json[JSONKey.courseTitle.rawValue].string
        self.courseCoverURL = json[JSONKey.courseCover.rawValue].string
        self.lessonID = json[JSONKey.lesson.rawValue].int
        self.lessonOwnerID = json[JSONKey.lessonOwner.rawValue].int
        self.lessonTitle = json[JSONKey.lessonTitle.rawValue].string
        self.lessonCoverURL = json[JSONKey.lessonCoverURL.rawValue].string
        self.stepID = json[JSONKey.step.rawValue].int
        self.stepPosition = json[JSONKey.stepPosition.rawValue].int
        self.commentID = json[JSONKey.comment.rawValue].int
        self.commentParentID = json[JSONKey.commentParent.rawValue].int
        self.commentUserID = json[JSONKey.commentUser.rawValue].int
        self.commentText = json[JSONKey.commentText.rawValue].string
    }

    enum JSONKey: String {
        case id
        case position
        case score
        case targetID = "target_id"
        case targetType = "target_type"
        case course
        case courseOwner = "course_owner"
        case courseAuthors = "course_authors"
        case courseTitle = "course_title"
        case courseCover = "course_cover"
        case lesson
        case lessonOwner = "lesson_owner"
        case lessonTitle = "lesson_title"
        case lessonCoverURL = "lesson_cover_url"
        case step
        case stepPosition = "step_position"
        case comment
        case commentParent = "comment_parent"
        case commentUser = "comment_user"
        case commentText = "comment_text"
    }
}
