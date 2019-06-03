import Foundation

/// Represents result of data fetching
struct FetchResult<T> {
    let value: T
    let source: Source

    enum Source {
        case cache
        case remote
    }
}
