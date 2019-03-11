import Foundation

typealias UniqueIdentifierType = String

protocol UniqueIdentifiable {
    var uniqueIdentifier: UniqueIdentifierType { get }
}
