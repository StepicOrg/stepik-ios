import Foundation

enum BlockType: String {
    case animation
    case chemical
    case choice
    case code
    case dataset
    case matching
    case math
    case number
    case puzzle
    case pycharm
    case sorting
    case sql
    case string
    case text
    case video
    case admin
    case table
    case html
    case schulte
    case fillBlanks = "fill-blanks"
    case freeAnswer = "free-answer"
    case linuxCode = "linux-code"
    case randomTasks = "random-tasks"
    case manualScore = "manual-score"

    static var theoryTypes: [BlockType] { [.text, .video] }

    var isTheory: Bool { Self.theoryTypes.contains(self) }
}
