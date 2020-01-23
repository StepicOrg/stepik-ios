import Foundation

extension String {
    /// Safely subscript string with index.
    ///
    ///     "Hello World!"[safe: 3] -> "l"
    ///     "Hello World!"[safe: 20] -> nil
    ///
    /// - Parameter index: index.
    subscript(safe index: Int) -> Character? {
        guard index >= 0 && index < self.count else {
            return nil
        }

        return self[self.index(self.startIndex, offsetBy: index)]
    }

    /// Safely subscript string within a half-open range.
    ///
    ///     "Hello World!"[safe: 6..<11] -> "World"
    ///     "Hello World!"[safe: 21..<110] -> nil
    ///
    /// - Parameter range: Half-open range.
    subscript(safe range: CountableRange<Int>) -> String? {
        guard let lowerIndex = self.index(
            self.startIndex,
            offsetBy: max(0, range.lowerBound),
            limitedBy: self.endIndex
        ) else {
            return nil
        }

        guard let upperIndex = self.index(
            lowerIndex,
            offsetBy: range.upperBound - range.lowerBound,
            limitedBy: self.endIndex
        ) else {
            return nil
        }

        return String(self[lowerIndex..<upperIndex])
    }

    /// Safely subscript string within a closed range.
    ///
    ///     "Hello World!"[safe: 6...11] -> "World!"
    ///     "Hello World!"[safe: 21...110] -> nil
    ///
    /// - Parameter range: Closed range.
    subscript(safe range: ClosedRange<Int>) -> String? {
        guard let lowerIndex = self.index(
            self.startIndex,
            offsetBy: max(0, range.lowerBound),
            limitedBy: self.endIndex
        ) else {
            return nil
        }

        guard let upperIndex = self.index(
            lowerIndex,
            offsetBy: range.upperBound - range.lowerBound,
            limitedBy: self.endIndex
        ) else {
            return nil
        }

        return String(self[lowerIndex...upperIndex])
    }
}
