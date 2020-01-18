import Foundation

enum StreamVideoQuality: Int, CaseIterable, UniqueIdentifiable {
    case low = 270
    case medium = 360
    case high = 720
    case veryHigh = 1080

    var uniqueIdentifier: UniqueIdentifierType { "\(self.rawValue)" }

    init?(uniqueIdentifier: UniqueIdentifierType) {
        if let value = Self.allCases.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
            self = value
        } else {
            return nil
        }
    }
}
