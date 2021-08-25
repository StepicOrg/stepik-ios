import Foundation
import SwiftyJSON

final class CodeReply: Reply {
    override class var supportsSecureCoding: Bool { true }

    var code: String
    var languageName: String

    var language: CodeLanguage? {
        CodeLanguage(rawValue: self.languageName)
    }

    override var dictValue: [String: Any] {
        [
            JSONKey.code.rawValue: self.code,
            JSONKey.language.rawValue: self.languageName
        ]
    }

    override var isEmpty: Bool { self.code.trimmed().isEmpty }

    override var hash: Int {
        var result = self.code.hashValue
        result = result &* 31 &+ self.languageName.hashValue
        return result
    }

    override var description: String {
        "CodeReply(code: \(self.code), language: \(self.languageName))"
    }

    init(code: String, languageName: String) {
        self.code = code
        self.languageName = languageName

        super.init()
    }

    convenience init(code: String, language: CodeLanguage) {
        self.init(code: code, languageName: language.rawValue)
    }

    /* Example data:
     {
       "language": "python3",
       "code": "def main():\n    pass"
     }
     */
    required init(json: JSON) {
        self.code = json[JSONKey.code.rawValue].stringValue
        self.languageName = json[JSONKey.language.rawValue].stringValue

        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let code = coder.decodeObject(forKey: JSONKey.code.rawValue) as? String,
              let languageName = coder.decodeObject(forKey: JSONKey.language.rawValue) as? String else {
            return nil
        }

        self.code = code
        self.languageName = languageName

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.code, forKey: JSONKey.code.rawValue)
        coder.encode(self.languageName, forKey: JSONKey.language.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? CodeReply else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.code != object.code { return false }
        if self.languageName != object.languageName { return false }
        return true
    }

    enum JSONKey: String {
        case code
        case language
    }
}
