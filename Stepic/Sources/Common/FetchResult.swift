import Foundation

/// Represents result of data fetching
struct FetchResult<T> {
    let value: T
    let source: Source

    enum Source {
        case cache
        case remote

        init(dataSource: DataSourceType) {
            switch dataSource {
            case .cache:
                self = .cache
            case .remote:
                self = .remote
            }
        }
    }
}
