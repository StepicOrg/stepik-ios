import Foundation
import PromiseKit

extension DispatchQueue {
    /// If current thread is main executes the block, otherwise schedules a block asynchronously for execution.
    /// - Parameter block: The block containing the work to perform.
    static func doWorkOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }

    func promise<U: Thenable>(execute body: @escaping () throws -> U) -> Promise<U.T> {
        Promise { seal in
            self.async {
                do {
                    try body().pipe(to: seal.resolve)
                } catch {
                    seal.reject(error)
                }
            }
        }
    }
}
