import Foundation

extension KeyedDecodingContainer {
    func decode<T: Decodable>(forKey key: Key) throws -> T {
        try self.decode(T.self, forKey: key)
    }

    func decode<T: Decodable>(
        forKey key: Key,
        default defaultExpression: @autoclosure () -> T
    ) throws -> T {
        try self.decodeIfPresent(T.self, forKey: key) ?? defaultExpression()
    }

    func decodeStepikDate(key: K) throws -> Date? {
        guard let dateString = try self.decodeIfPresent(String.self, forKey: key) else {
            return nil
        }

        return DateFormatter.parsedStepikISO8601Date(from: dateString)
    }
}
