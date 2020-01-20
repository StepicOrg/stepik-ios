import Foundation

protocol StoredFileProtocol {
    /// URL for stored video
    var localURL: URL { get }
    /// File size in bytes
    var size: UInt64 { get }
}

struct StoredFile: StoredFileProtocol {
    let localURL: URL
    let size: UInt64
}
