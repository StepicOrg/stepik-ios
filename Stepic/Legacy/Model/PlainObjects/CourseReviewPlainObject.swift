import Foundation

struct CourseReviewPlainObject {
    let id: Int
    let courseID: Int
    let userID: Int
    let score: Int
    let text: String
    let creationDate: Date
    var course: CoursePlainObject?
}

extension CourseReviewPlainObject {
    init(courseReview: CourseReview) {
        self.id = courseReview.id
        self.courseID = courseReview.courseID
        self.userID = courseReview.userID
        self.score = courseReview.score
        self.text = courseReview.text
        self.creationDate = courseReview.creationDate

        if let course = courseReview.course {
            self.course = CoursePlainObject(course: course, withSections: false)
        }
    }
}
