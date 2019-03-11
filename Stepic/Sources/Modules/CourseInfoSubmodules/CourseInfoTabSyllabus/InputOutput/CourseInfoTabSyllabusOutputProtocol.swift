import Foundation

protocol CourseInfoTabSyllabusOutputProtocol: class {
    func presentLesson(in unit: Unit)
    func presentExamLesson()
    func presentPersonalDeadlinesCreation(for course: Course)
    func presentPersonalDeadlinesSettings(for course: Course)
}
