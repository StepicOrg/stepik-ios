import Foundation
import Nuke
import Regex

/// Represents a data provider to provide image data.
protocol ImageDataProvider {
    /// Provides the data which represents image.
    var data: Data? { get }

    /// The content URL represents this provider, if exists.
    var contentURL: URL? { get }
}

extension ImageDataProvider {
    var contentURL: URL? { nil }
}

/// Represents an image data provider for loading from a local file URL on disk.
struct LocalFileImageDataProvider: ImageDataProvider {
    // MARK: Properties

    /// The file URL from which the image be loaded.
    let fileURL: URL

    // MARK: Initializers

    /// Creates an image data provider by supplying the target local file URL.
    ///
    /// - Parameters:
    ///   - fileURL: The file URL from which the image be loaded.
    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    // MARK: Protocol Conforming
    var data: Data? {
        try? Data(contentsOf: self.fileURL)
    }

    /// The URL of the local file on the disk.
    var contentURL: URL? { self.fileURL }
}

/// Represents an image data provider for loading image from a given Base64 encoded string.
struct Base64ImageDataProvider: ImageDataProvider {
    // MARK: Properties
    /// The encoded Base64 string for the image.
    let base64String: String

    // MARK: Initializers

    /// Creates an image data provider by supplying the Base64 encoded string.
    ///
    /// - Parameters:
    ///   - base64String: The Base64 encoded string for an image.
    init(base64String: String) {
        self.base64String = base64String
    }

    /// Creates an image data provider by supplying the possibly Base64 encoded string.
    /// Supplied string will be sanitized if needed.
    ///
    /// - Parameters:
    ///   - base64String: The possibly Base64 encoded string for an image.
    init(base64StringOrNot: String) {
        self.base64String = Self.sanitize(string: base64StringOrNot)
    }

    // MARK: Protocol Conforming

    var data: Data? {
        Data(base64Encoded: self.base64String)
    }

    private static func sanitize(string: String) -> String {
        if let regex = try? Regex(string: "(data:.*,)", options: [.ignoreCase]) {
            var replacedString = string

            replacedString.replaceFirst(matching: regex, with: "")
            replacedString = replacedString.removingPercentEncoding ?? replacedString
            replacedString = replacedString.trimmingCharacters(in: .whitespaces)

            return replacedString
        }

        return string
    }
}

/// Represents an image data provider for loading image from a Nuke image cache layer.
final class NukeImageDataProvider: ImageDataProvider {
    private let imageRequest: ImageRequest
    private let imageCache: ImageCache

    private let compressionQuality: CGFloat

    init(imageRequest: ImageRequest, imageCache: ImageCache, compressionQuality: CGFloat) {
        self.imageRequest = imageRequest
        self.imageCache = imageCache
        self.compressionQuality = compressionQuality
    }

    convenience init(url: URL, imageCache: ImageCache = .shared, compressionQuality: CGFloat = 0.9) {
        self.init(imageRequest: ImageRequest(url: url), imageCache: imageCache, compressionQuality: compressionQuality)
    }

    var data: Data? {
        guard let imageContainer = self.imageCache[self.imageRequest] else {
            return nil
        }

        return imageContainer.image.jpegData(compressionQuality: self.compressionQuality)
    }

    var contentURL: URL? { self.imageRequest.urlRequest?.url }
}
