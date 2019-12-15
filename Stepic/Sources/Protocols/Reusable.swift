import UIKit

protocol Reusable: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension Reusable where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
