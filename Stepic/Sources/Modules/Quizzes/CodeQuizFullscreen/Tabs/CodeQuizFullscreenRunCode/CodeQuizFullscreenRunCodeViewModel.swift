import Foundation

struct CodeQuizFullscreenRunCodeViewModel {
    let testInput: String?
    let testOutput: String?
    let userCodeRunStatus: UserCodeRun.Status?
    let shouldShowTestInput: Bool
    let shouldShowTestOutput: Bool
    let isSamplesButtonEnabled: Bool
    let isRunCodeButtonEnabled: Bool
}
