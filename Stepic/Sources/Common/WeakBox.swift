import Foundation

final class WeakBox<T: AnyObject> {
    weak var value: T?

    init(_ value: T) {
        self.value = value
    }
}
