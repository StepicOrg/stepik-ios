import Foundation

enum Formatter {
    static func progress(_ progress: Float) -> String {
        let hasDecimals = progress.truncatingRemainder(dividingBy: 1) != 0
        let stringValue = hasDecimals ? String(format: "%.2f", progress) : "\(Int(progress))"
        return "\(stringValue)%"
    }
}
