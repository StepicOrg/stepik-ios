import Foundation

struct InstructionDataPlainObject {
    let instruction: InstructionPlainObject
    let rubrics: [RubricPlainObject]

    var maxScore: Int {
        self.rubrics.map(\.cost).reduce(0, +)
    }
}
