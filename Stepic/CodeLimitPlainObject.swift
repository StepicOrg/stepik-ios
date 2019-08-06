import Foundation

struct CodeLimitPlainObject {
    let language: String?
    let memory: Double
    let time: TimeInterval
}

extension CodeLimitPlainObject {
    init(codeLimit: CodeLimit) {
        self.language = codeLimit.languageString
        self.memory = codeLimit.memory
        self.time = codeLimit.time
    }
}
