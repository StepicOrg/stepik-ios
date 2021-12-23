import Foundation

enum DataFetchPolicy {
    /// Firstly executes the request against the cache.
    /// If requested data is present in the cache, that data is returned.
    /// Otherwise, executes the request against the network and returns that data after caching it.
    case cacheFirst
    /// Firstly executes the request against the network.
    /// If server-side returns the result, that data is returned.
    /// Otherwise, executes the request against the cache and returns that data.
    case remoteFirst
}
