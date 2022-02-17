import Foundation

private class BundleResolver {}

extension Bundle {
    static var module: Bundle {
        Bundle(for: BundleResolver.self)
    }
}
