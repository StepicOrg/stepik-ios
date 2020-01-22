import Foundation

protocol StoredFileProtocol {
    /// URL for stored file
    var localURL: URL { get }
    /// File size in bytes
    var size: UInt64 { get }
}

extension StoredFileProtocol {
    var data: Data? { try? Data(contentsOf: self.localURL) }
}

struct StoredFile: StoredFileProtocol {
    let localURL: URL
    let size: UInt64
}
