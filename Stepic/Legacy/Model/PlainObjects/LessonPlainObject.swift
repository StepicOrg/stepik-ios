import Foundation

struct LessonPlainObject {
    let id: Int
    let title: String
    let coverURL: String?
    let isFeatured: Bool
    let isPublic: Bool
    let canEdit: Bool
    let canLearnLesson: Bool
    let stepsIDs: [Int]
    let steps: [StepPlainObject]
    let timeToComplete: Double
    let voteDelta: Int
    let passedBy: Int
}

extension LessonPlainObject {
    init(lesson: Lesson) {
        self.id = lesson.id
        self.title = lesson.title
        self.coverURL = lesson.coverURL
        self.isFeatured = lesson.isFeatured
        self.isPublic = lesson.isPublic
        self.canEdit = lesson.canEdit
        self.canLearnLesson = lesson.canLearnLesson
        self.stepsIDs = lesson.stepsArray
        self.steps = lesson.steps.map(StepPlainObject.init)
        self.timeToComplete = lesson.timeToComplete
        self.voteDelta = lesson.voteDelta
        self.passedBy = lesson.passedBy
    }
}
