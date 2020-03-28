import Foundation

// TODO: Replace StepikResult type with Swift’s Result type.

@available(*, deprecated, message: "Use Swift’s Result type.")
enum StepikResult<T> {
    case success(T)
    case failure(Swift.Error)
}
