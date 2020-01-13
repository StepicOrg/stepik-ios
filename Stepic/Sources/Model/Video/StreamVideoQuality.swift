import Foundation

enum StreamVideoQuality: Int, CaseIterable {
    case low = 270
    case medium = 360
    case high = 720
    case veryHigh = 1080

    var description: String { "\(self.rawValue)" }

    init?(qualityString: String) {
        if let quality = Self.allCases.first(where: { $0.description == qualityString }) {
            self = quality
        } else {
            return nil
        }
    }
}
