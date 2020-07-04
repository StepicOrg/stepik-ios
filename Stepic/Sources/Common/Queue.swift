import Foundation

/// First-in first-out queue (FIFO)
struct Queue<T> {
    private var array = [T?]()
    private var headIdx = 0

    private let emptySpotsThreshold: Double
    private let minElementsToTrimArray: Int

    init(
        emptySpotsThreshold: Double = 0.25,
        minElementsToTrimArray: Int = 50
    ) {
        self.emptySpotsThreshold = emptySpotsThreshold
        self.minElementsToTrimArray = minElementsToTrimArray
    }

    var count: Int {
        self.array.count - self.headIdx
    }

    var isEmpty: Bool {
        // swiftlint:disable:next empty_count
        self.count == 0
    }

    mutating func enqueue(_ element: T) {
        self.array.append(element)
    }

    mutating func dequeue() -> T? {
        guard let element = self.array[guarded: self.headIdx] else {
            return nil
        }

        self.array[self.headIdx] = nil
        self.headIdx += 1

        let emptySpotsPercentage = Double(self.headIdx) / Double(self.array.count)
        let shouldTrimArray = self.array.count > self.minElementsToTrimArray
            && emptySpotsPercentage > self.emptySpotsThreshold

        if shouldTrimArray {
            self.array.removeFirst(self.headIdx)
            self.headIdx = 0
        }

        return element
    }
}

private extension Array {
    subscript(guarded idx: Int) -> Element? {
        guard (self.startIndex..<self.endIndex).contains(idx) else {
            return nil
        }
        return self[idx]
    }
}
