import Foundation

struct CoursePlainObject {
    let id: Int
    let title: String
    let sectionsIDs: [Int]
    let sections: [SectionPlainObject]
    let isEnrolled: Bool
    let isPaid: Bool
}

extension CoursePlainObject {
    init(course: Course) {
        self.id = course.id
        self.title = course.title
        self.sectionsIDs = course.sectionsArray
        self.sections = course.sections.map(SectionPlainObject.init)
        self.isEnrolled = course.enrolled
        self.isPaid = course.isPaid
    }
}
