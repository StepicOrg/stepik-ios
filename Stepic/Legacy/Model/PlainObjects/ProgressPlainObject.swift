import Foundation

struct ProgressPlainObject: Equatable {
    let id: String
    let isPassed: Bool
    let score: Float
    let cost: Int
    let numberOfSteps: Int
    let numberOfStepsPassed: Int

    var percentPassed: Float {
        self.numberOfSteps != 0
            ? Float(self.numberOfStepsPassed) / Float(self.numberOfSteps) * 100
            : 100.0
    }
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
