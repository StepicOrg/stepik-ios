import Foundation

struct CoursePlainObject {
    let id: Int
    let title: String
    let coverURLString: String
    let sectionsIDs: [Int]
    let sections: [SectionPlainObject]
    let isEnrolled: Bool
    let isPaid: Bool
    let isProctored: Bool
}

extension CoursePlainObject {
    init(course: Course, withSections: Bool = true) {
        self.id = course.id
        self.title = course.title
        self.coverURLString = course.coverURLString
        self.sectionsIDs = course.sectionsArray
        self.sections = withSections ? course.sections.map(SectionPlainObject.init) : []
        self.isEnrolled = course.enrolled
        self.isPaid = course.isPaid
        self.isProctored = course.isProctored
    }
}
