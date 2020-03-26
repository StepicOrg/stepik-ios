import Foundation

extension Array {
    /// Reorder elements in custom order of transformed objects
    func reordered<T: Hashable & Equatable>(order: [T], transform: (Element) -> T) -> [Element] {
        var uniqueOrder: [T] = []
        order.forEach { item in
            if !uniqueOrder.contains(item) {
                uniqueOrder.append(item)
            }
        }

        let ordering = [T: Int](
            uniqueKeysWithValues: uniqueOrder.enumerated().map { ($1, $0) }
        )

        return self.sorted { lhs, rhs -> Bool in
            if let first = ordering[transform(lhs)],
               let second = ordering[transform(rhs)] {
                return first < second
            }
            return false
        }
    }
}
