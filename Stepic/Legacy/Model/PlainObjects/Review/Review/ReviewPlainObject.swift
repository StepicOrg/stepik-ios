import Foundation
import SwiftyJSON

struct ReviewPlainObject: Equatable {
    let id: Int
    let session: Int?
    let targetSession: Int?
    let text: String
    let rubricScores: [Int]
    let submission: Int?
    let whenFinished: Date?
    let isVerified: Bool
    let isFrozen: Bool
}

extension ReviewPlainObject {
    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.session = json[JSONKey.session.rawValue].int
        self.targetSession = json[JSONKey.targetSession.rawValue].int
        self.text = json[JSONKey.text.rawValue].stringValue
        self.rubricScores = json[JSONKey.rubricScores.rawValue].arrayValue.compactMap(\.int)
        self.submission = json[JSONKey.submission.rawValue].int
        self.whenFinished = Parser.dateFromTimedateJSON(json[JSONKey.whenFinished.rawValue])
        self.isVerified = json[JSONKey.isVerified.rawValue].boolValue
        self.isFrozen = json[JSONKey.isFrozen.rawValue].boolValue
    }

    enum JSONKey: String {
        case id
        case session
        case targetSession = "target_session"
        case text
        case rubricScores = "rubric_scores"
        case submission
        case whenFinished = "when_finished"
        case isVerified = "is_verified"
        case isFrozen = "is_frozen"
    }
}
