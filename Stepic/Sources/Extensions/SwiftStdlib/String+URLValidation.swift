import Foundation

extension String {
    /// Check if string is a valid http protocol URL.
    ///
    /// `"http://google.com".isValidHttpUrl -> true`
    /// `"https://google.com".isValidHttpsUrl -> true`
    var isValidHttpUrl: Bool {
        guard let url = URL(string: self) else {
            return false
        }

        return ["http", "https"].contains(url.scheme)
    }
}
