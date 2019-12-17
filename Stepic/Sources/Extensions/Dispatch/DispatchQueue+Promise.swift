import Foundation
import PromiseKit

extension DispatchQueue {
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
