import Foundation

struct AssignmentPlainObject {
    let id: Int
    let stepID: Int
    let unitID: Int
    let progressID: String
    let progress: ProgressPlainObject?
}

extension AssignmentPlainObject {
    init(assignment: Assignment) {
        self.id = assignment.id
        self.stepID = assignment.stepId
        self.unitID = assignment.unitId
        self.progressID = assignment.progressId

        if let progressEntity = assignment.progress {
            self.progress = ProgressPlainObject(progress: progressEntity)
        } else {
            self.progress = nil
        }
    }
}
