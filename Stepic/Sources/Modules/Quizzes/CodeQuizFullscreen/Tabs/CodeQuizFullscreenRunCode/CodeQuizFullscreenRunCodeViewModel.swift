import Foundation

struct CodeQuizFullscreenRunCodeViewModel {
    let testInput: String?
    let testOutput: String?
    let userCodeRunStatus: UserCodeRun.Status?
    let shouldShowTestOutput: Bool
    let isSamplesButtonEnabled: Bool
    let isRunCodeButtonEnabled: Bool
}
