import Foundation

enum VideoRate: Float, CaseIterable, UniqueIdentifiable {
    case verySlow = 0.5
    case slow = 0.75
    case normal = 1
    case slightlyFast = 1.25
    case fast = 1.5
    case veryFast = 1.75
    case doubleFast = 2.0

    var uniqueIdentifier: UniqueIdentifierType { "\(self.rawValue)" }

    // If the value is a maximal rate, it cyclically gets the lowest one
    var nextValue: VideoRate {
        if let index = Self.allCases.firstIndex(of: self) {
            if index < Self.allCases.count - 1 {
                return Self.allCases[index + 1]
            } else {
                return VideoRate.allCases[index]
            }
        }
        return self
    }

    init?(uniqueIdentifier: UniqueIdentifierType) {
        if let value = Self.allCases.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
            self = value
        } else {
            return nil
        }
    }
}
