import Foundation

struct ProgressPlainObject: Equatable {
    let id: String
    let isPassed: Bool
    let score: Float
    let cost: Int
    let numberOfSteps: Int
    let numberOfStepsPassed: Int
}

extension ProgressPlainObject {
    init(progress: Progress) {
        self.id = progress.id
        self.isPassed = progress.isPassed
        self.score = progress.score
        self.cost = progress.cost
        self.numberOfSteps = progress.numberOfSteps
        self.numberOfStepsPassed = progress.numberOfStepsPassed
    }
}
