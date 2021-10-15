import Foundation

extension Dictionary {
    /// Returns a dictionary containing the results of mapping the given closure over the sequence’s elements.
    /// - Parameter transform: A mapping closure. `transform` accepts an element of this sequence as its parameter and
    /// returns a transformed value of the same or of a different type.
    /// - Returns: A dictionary containing the transformed elements of this sequence.
    func mapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)) rethrows -> [K: V] {
        [K: V](uniqueKeysWithValues: try map(transform))
    }

    /// Returns a dictionary containing the non-`nil` results of calling the given transformation with each element of this sequence.
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: A dictionary of the non-`nil` results of calling `transform` with each element of the sequence.
    /// - Complexity: *O(m + n)*, where _m_ is the length of this sequence and _n_ is the length of the result.
    func compactMapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)?) rethrows -> [K: V] {
        [K: V](uniqueKeysWithValues: try compactMap(transform))
    }
}
