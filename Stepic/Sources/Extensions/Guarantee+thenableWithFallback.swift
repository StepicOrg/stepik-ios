import Foundation
import PromiseKit

extension Guarantee {
    convenience init<U: Thenable>(_ thenable: U, fallback: U.T? = nil) where T == U.T? {
        self.init { seal in
            thenable.done { result in
                seal(result)
            }.catch { _ in
                seal(fallback)
            }
        }
    }
}
