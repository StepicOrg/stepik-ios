import Foundation
import PromiseKit

func attempt<T>(
    retryLimit: Int = 2,
    delayBeforeRetry: DispatchTimeInterval = .seconds(2),
    _ body: @escaping () -> Promise<T>
) -> Promise<T> {
    var attempts = 0

    func attempt() -> Promise<T> {
        attempts += 1
        return body().recover { error -> Promise<T> in
            guard attempts < retryLimit else {
                throw error
            }

            return after(delayBeforeRetry).then(on: nil, attempt)
        }
    }

    return attempt()
}
