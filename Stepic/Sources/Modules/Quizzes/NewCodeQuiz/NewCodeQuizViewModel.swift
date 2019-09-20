import UIKit

struct NewCodeQuizViewModel {
    let title: String?
    let code: String?
    let codeTemplate: String?
    let language: CodeLanguage?
    let languages: [CodeLanguage]
    let samples: [CodeSamplePlainObject]
    let limit: CodeLimitPlainObject
    let codeEditorTheme: CodeEditorTheme
    let finalState: State

    enum State {
        case `default`
        case correct
        case wrong
        case evaluation
        case noLanguage
        case unsupportedLanguage
    }
}
