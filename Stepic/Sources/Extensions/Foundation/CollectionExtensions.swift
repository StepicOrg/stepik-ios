import Foundation

extension Collection {
    /// Safe protects the array from out of bounds by use of optional.
    ///
    ///        let arr = [1, 2, 3, 4, 5]
    ///        arr[safe: 1] -> 2
    ///        arr[safe: 10] -> nil
    ///
    /// - Parameter index: index of element to access element.
    subscript(safe index: Index) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }

    /// Returns an array of slices of length "size" from the array.
    /// If array can't be split evenly, the final slice will be the remaining elements.
    ///
    ///     [0, 2, 4, 7].group(by: 2) -> [[0, 2], [4, 7]]
    ///     [0, 2, 4, 7, 6].group(by: 2) -> [[0, 2], [4, 7], [6]]
    ///
    /// - Parameter size: The size of the slices to be returned.
    /// - Returns: grouped self.
    func group(by size: Int) -> [[Element]]? {
        guard size > 0, !self.isEmpty else {
            return nil
        }

        var start = self.startIndex
        var slices = [[Element]]()

        while start != self.endIndex {
            let end = self.index(start, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            slices.append(Array(self[start..<end]))
            start = end
        }

        return slices
    }
}
