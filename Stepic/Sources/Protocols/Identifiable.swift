import Foundation

protocol Identifiable {
    // swiftlint:disable:next type_name
    associatedtype ID: Hashable
    var id: ID { get }
}
