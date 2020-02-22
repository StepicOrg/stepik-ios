import Foundation
import SwiftyJSON

final class UserCodeRun: JSONSerializable {
    typealias IdType = Int

    var id: IdType = -1
    var userID: User.IdType = -1
    var stepID: Step.IdType = -1
    var languageString: String = ""
    var code: String = ""
    var statusString: String?
    var stdin: String?
    var stdout: String?
    var stderr: String?
    var timeLimitExceeded: Bool = false
    var memoryLimitExceeded: Bool = false
    var createDateString: String?
    var updateDateString: String?

    var language: CodeLanguage? { CodeLanguage(rawValue: self.languageString) }
    var status: Status? {
        get {
            Status(rawValue: self.statusString ?? "")
        }
        set {
            self.statusString = newValue?.rawValue
        }
    }

    var json: JSON {
        [
            JSONKey.language.rawValue: self.languageString,
            JSONKey.code.rawValue: self.code,
            JSONKey.stdin.rawValue: self.stdin ?? "",
            JSONKey.step.rawValue: self.stepID,
            JSONKey.user.rawValue: self.userID
        ]
    }

    /// Initializer for POST request usage.
    init(userID: User.IdType, stepID: Step.IdType, languageString: String, code: String, stdin: String) {
        self.userID = userID
        self.stepID = stepID
        self.languageString = languageString
        self.code = code
        self.stdin = stdin
    }

    init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.stepID = json[JSONKey.step.rawValue].intValue
        self.languageString = json[JSONKey.language.rawValue].stringValue
        self.code = json[JSONKey.code.rawValue].stringValue
        self.statusString = json[JSONKey.status.rawValue].string
        self.stdin = json[JSONKey.stdin.rawValue].string
        self.stdout = json[JSONKey.stdout.rawValue].string
        self.stderr = json[JSONKey.stderr.rawValue].string
        self.timeLimitExceeded = json[JSONKey.timeLimitExceeded.rawValue].boolValue
        self.memoryLimitExceeded = json[JSONKey.memoryLimitExceeded.rawValue].boolValue
        self.createDateString = json[JSONKey.createDate.rawValue].string
        self.updateDateString = json[JSONKey.updateDate.rawValue].string
    }

    // MARK: Types

    enum Status: String {
        case failure
        case success
        case evaluation
    }

    enum JSONKey: String {
        case id
        case user
        case step
        case language
        case code
        case status
        case stdin
        case stdout
        case stderr
        case timeLimitExceeded = "time_limit_exceeded"
        case memoryLimitExceeded = "memory_limit_exceeded"
        case createDate = "create_date"
        case updateDate = "update_date"
    }
}

extension UserCodeRun: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        UserCodeRun(id: \(self.id), \
        userID: \(self.userID), \
        stepID: \(self.stepID), \
        languageString: \(self.languageString), \
        code: \(self.code), \
        statusString: \(self.statusString ??? "nil"), \
        stdin: \(self.stdin ??? "nil"), \
        stdout: \(self.stdout ??? "nil"), \
        stderr: \(self.stderr ??? "nil"), \
        timeLimitExceeded: \(self.timeLimitExceeded), \
        memoryLimitExceeded: \(self.memoryLimitExceeded), \
        createDateString: \(self.createDateString ??? "nil"), \
        updateDateString: \(self.updateDateString ??? "nil"))
        """
    }
}
