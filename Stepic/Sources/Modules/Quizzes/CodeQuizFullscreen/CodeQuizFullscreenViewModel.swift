import Foundation

struct CodeQuizFullscreenViewModel {
    let content: String
    let samples: [CodeSamplePlainObject]
    let limit: CodeLimitPlainObject
    let language: CodeLanguage
    let code: String?
    let codeTemplate: String?
}
