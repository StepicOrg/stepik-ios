import Foundation

struct UnitPlainObject {
    let id: Int
    let sectionID: Int
    let progressID: String?
    let lessonID: Int
    let position: Int
    let beginDate: Date?
    let softDeadline: Date?
    let hardDeadline: Date?
    let isActive: Bool
    let progress: ProgressPlainObject?
    let lesson: LessonPlainObject?
    let assignmentsIDs: [Int]
    let assignments: [AssignmentPlainObject]
}

extension UnitPlainObject {
    init(unit: Unit) {
        self.id = unit.id
        self.sectionID = unit.sectionId
        self.progressID = unit.progressId
        self.lessonID = unit.lessonId
        self.position = unit.position
        self.beginDate = unit.beginDate
        self.softDeadline = unit.softDeadline
        self.hardDeadline = unit.hardDeadline
        self.isActive = unit.isActive

        if let progressEntity = unit.progress {
            self.progress = ProgressPlainObject(progress: progressEntity)
        } else {
            self.progress = nil
        }

        if let lessonEntity = unit.lesson {
            self.lesson = LessonPlainObject(lesson: lessonEntity)
        } else {
            self.lesson = nil
        }

        self.assignmentsIDs = unit.assignmentsArray
        self.assignments = unit.assignments.map(AssignmentPlainObject.init)
    }
}
