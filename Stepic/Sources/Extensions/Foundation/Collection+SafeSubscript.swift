import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }
}
