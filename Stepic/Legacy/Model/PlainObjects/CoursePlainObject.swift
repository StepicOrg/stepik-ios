import Foundation

struct CoursePlainObject {
    var id: Int
    var sectionsIDs: [Int]
    var sections: [SectionPlainObject]
}

extension CoursePlainObject {
    init(course: Course) {
        self.id = course.id
        self.sectionsIDs = course.sectionsArray
        self.sections = course.sections.map(SectionPlainObject.init)
    }
}
