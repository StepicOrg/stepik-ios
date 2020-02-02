import Foundation
import SwiftyJSON

final class CodeReply: Reply {
    var code: String
    var languageName: String

    var language: CodeLanguage? {
        CodeLanguage(rawValue: self.languageName)
    }

    var dictValue: [String: Any] {
        [
            JSONKey.code.rawValue: self.code,
            JSONKey.language.rawValue: self.languageName
        ]
    }

    var description: String {
        "CodeReply(code: \(self.code), language: \(self.languageName))"
    }

    init(code: String, languageName: String) {
        self.code = code
        self.languageName = languageName
    }

    init(code: String, language: CodeLanguage) {
        self.code = code
        self.languageName = language.rawValue
    }

    required init(json: JSON) {
        self.code = json[JSONKey.code.rawValue].stringValue
        self.languageName = json[JSONKey.language.rawValue].stringValue
    }

    enum JSONKey: String {
        case code
        case language
    }
}

extension CodeReply: Hashable {
    static func == (lhs: CodeReply, rhs: CodeReply) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.code != rhs.code { return false }
        if lhs.languageName != rhs.languageName { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.code)
        hasher.combine(self.languageName)
    }
}
