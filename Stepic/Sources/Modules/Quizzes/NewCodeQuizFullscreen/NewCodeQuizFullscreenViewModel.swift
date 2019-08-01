import Foundation

struct NewCodeQuizFullscreenViewModel {
    let content: String
    let samples: [NewCodeQuiz.CodeSample]
    let limit: NewCodeQuiz.CodeLimit
    let language: CodeLanguage
    let code: String?
    let codeTemplate: String?
    let codeEditorTheme: CodeEditorView.Theme
}
