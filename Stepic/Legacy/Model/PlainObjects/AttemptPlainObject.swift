import Foundation

struct AttemptPlainObject: Equatable {
    let id: Int
    let dataset: Dataset?
    let datasetURL: String?
    let time: String?
    let status: String?
    let stepID: Step.IdType
    let timeLeft: String?
    let userID: User.IdType?

    static func == (lhs: AttemptPlainObject, rhs: AttemptPlainObject) -> Bool {
        if lhs.id != rhs.id { return false }

        if let dataset = lhs.dataset {
            if !dataset.isEqual(rhs.dataset) { return false }
        } else if rhs.dataset != nil { return false }

        if lhs.datasetURL != rhs.datasetURL { return false }
        if lhs.time != rhs.time { return false }
        if lhs.status != rhs.status { return false }
        if lhs.stepID != rhs.stepID { return false }
        if lhs.timeLeft != rhs.timeLeft { return false }
        if lhs.userID != rhs.userID { return false }

        return true
    }
}

extension AttemptPlainObject {
    init(attempt: Attempt) {
        self.id = attempt.id
        self.dataset = attempt.dataset?.copy() as? Dataset
        self.datasetURL = attempt.datasetURL
        self.time = attempt.time
        self.status = attempt.status
        self.stepID = attempt.stepID
        self.timeLeft = attempt.timeLeft
        self.userID = attempt.userID
    }

    init(attemptEntity: AttemptEntity) {
        self.init(attempt: attemptEntity.plainObject)
    }
}
