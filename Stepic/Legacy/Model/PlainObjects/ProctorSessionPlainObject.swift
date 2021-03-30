import Foundation

struct ProctorSessionPlainObject {
    let id: Int
    let userID: Int
    let sectionID: Int
    let startURL: String?
    let stopURL: String?
    let createDate: Date?
    let startDate: Date?
    let stopDate: Date?
    let submitDate: Date?
    let comment: String
    let score: Float
}

extension ProctorSessionPlainObject {
    init(proctorSession: ProctorSession) {
        self.id = proctorSession.id
        self.userID = proctorSession.userId
        self.sectionID = proctorSession.sectionId
        self.startURL = proctorSession.startUrl
        self.stopURL = proctorSession.stopUrl
        self.createDate = proctorSession.createDate
        self.startDate = proctorSession.startDate
        self.stopDate = proctorSession.stopDate
        self.submitDate = proctorSession.submitDate
        self.comment = proctorSession.comment
        self.score = proctorSession.score
    }
}
