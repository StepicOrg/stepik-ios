import Foundation

final class CachedValue<T> {
    private let defaults = UserDefaults.standard

    private let key: String

    private var privateValue: T?
    private var defaultValue: T

    var value: T {
        get {
            if self.privateValue == nil {
                self.privateValue = self.defaults.value(forKey: self.key) as? T
            }
            return self.privateValue ?? self.defaultValue
        }
        set {
            self.defaults.set(newValue, forKey: self.key)
            self.privateValue = newValue
        }
    }

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    convenience init(key: String, value: T, defaultValue: T) {
        self.init(key: key, defaultValue: defaultValue)
        self.value = value
    }
}
