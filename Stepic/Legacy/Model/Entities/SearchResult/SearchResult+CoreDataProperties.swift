import CoreData
import Foundation

extension SearchResult {
    @NSManaged var managedId: NSNumber
    @NSManaged var managedPosition: NSNumber
    @NSManaged var managedScore: NSNumber
    // Target
    @NSManaged var managedTargetId: NSNumber
    @NSManaged var managedTargetTypeString: String
    // Course
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedCourseOwnerId: NSNumber?
    @NSManaged var managedCourseAuthorsArray: NSObject?
    @NSManaged var managedCourseTitle: String?
    @NSManaged var managedCourseCover: String?
    // Lesson
    @NSManaged var managedLessonId: NSNumber?
    @NSManaged var managedLessonOwnerId: NSNumber?
    @NSManaged var managedLessonTitle: String?
    @NSManaged var managedLessonCover: String?
    // Step
    @NSManaged var managedStepId: NSNumber?
    @NSManaged var managedStepPosition: NSNumber?
    // Comment
    @NSManaged var managedCommentId: NSNumber?
    @NSManaged var managedCommentParentId: NSNumber?
    @NSManaged var managedCommentUserId: NSNumber?
    @NSManaged var managedCommentText: String?

    @NSManaged var managedSearchQueryResult: SearchQueryResult?

    var id: Int {
        get {
            self.managedId.intValue
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var position: Int {
        get {
            self.managedPosition.intValue
        }
        set {
            self.managedPosition = NSNumber(value: newValue)
        }
    }

    var score: Float {
        get {
            self.managedScore.floatValue
        }
        set {
            self.managedScore = NSNumber(value: newValue)
        }
    }

    var targetID: Int {
        get {
            self.managedTargetId.intValue
        }
        set {
            self.managedTargetId = NSNumber(value: newValue)
        }
    }

    var targetTypeString: String {
        get {
            self.managedTargetTypeString
        }
        set {
            self.managedTargetTypeString = newValue
        }
    }

    var courseID: Course.IdType? {
        get {
            self.managedCourseId?.intValue
        }
        set {
            self.managedCourseId = newValue as NSNumber?
        }
    }

    var courseOwnerID: User.IdType? {
        get {
            self.managedCourseOwnerId?.intValue
        }
        set {
            self.managedCourseOwnerId = newValue as NSNumber?
        }
    }

    var courseAuthorsArray: [User.IdType]? {
        get {
            self.managedCourseAuthorsArray as? [User.IdType]
        }
        set {
            if let newValue = newValue {
                self.managedCourseAuthorsArray = NSArray(array: newValue)
            } else {
                self.managedCourseAuthorsArray = nil
            }
        }
    }

    var courseTitle: String? {
        get {
            self.managedCourseTitle
        }
        set {
            self.managedCourseTitle = newValue
        }
    }

    var courseCover: String? {
        get {
            self.managedCourseCover
        }
        set {
            self.managedCourseCover = newValue
        }
    }

    var lessonID: Lesson.IdType? {
        get {
            self.managedLessonId?.intValue
        }
        set {
            self.managedLessonId = newValue as NSNumber?
        }
    }

    var lessonOwnerID: User.IdType? {
        get {
            self.managedLessonOwnerId?.intValue
        }
        set {
            self.managedLessonOwnerId = newValue as NSNumber?
        }
    }

    var lessonTitle: String? {
        get {
            self.managedLessonTitle
        }
        set {
            self.managedLessonTitle = newValue
        }
    }

    var lessonCover: String? {
        get {
            self.managedLessonCover
        }
        set {
            self.managedLessonCover = newValue
        }
    }

    var stepID: Step.IdType? {
        get {
            self.managedStepId?.intValue
        }
        set {
            self.managedStepId = newValue as NSNumber?
        }
    }

    var stepPosition: Int? {
        get {
            self.managedStepPosition?.intValue
        }
        set {
            self.managedStepPosition = newValue as NSNumber?
        }
    }

    var commentID: Comment.IdType? {
        get {
            self.managedCommentId?.intValue
        }
        set {
            self.managedCommentId = newValue as NSNumber?
        }
    }

    var commentParentID: Comment.IdType? {
        get {
            self.managedCommentParentId?.intValue
        }
        set {
            self.managedCommentParentId = newValue as NSNumber?
        }
    }

    var commentUserID: User.IdType? {
        get {
            self.managedCommentUserId?.intValue
        }
        set {
            self.managedCommentUserId = newValue as NSNumber?
        }
    }

    var commentText: String? {
        get {
            self.managedCommentText
        }
        set {
            self.managedCommentText = newValue
        }
    }

    var searchQueryResult: SearchQueryResult? {
        get {
            self.managedSearchQueryResult
        }
        set {
            self.managedSearchQueryResult = newValue
        }
    }
}
