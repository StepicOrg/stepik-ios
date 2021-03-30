import Foundation

struct ExamSessionPlainObject {
    let id: Int
    let userID: Int
    let sectionID: Int
    let beginDate: Date?
    let endDate: Date?
    let timeLeft: Float
}

extension ExamSessionPlainObject {
    init(examSession: ExamSession) {
        self.id = examSession.id
        self.userID = examSession.userId
        self.sectionID = examSession.sectionId
        self.beginDate = examSession.beginDate
        self.endDate = examSession.endDate
        self.timeLeft = examSession.timeLeft
    }
}
