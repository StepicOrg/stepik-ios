import Foundation

@propertyWrapper
struct Trimmed {
    var wrappedValue: String {
        didSet {
            self.wrappedValue = self.wrappedValue.trimmed()
        }
    }

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.trimmed()
    }
}
