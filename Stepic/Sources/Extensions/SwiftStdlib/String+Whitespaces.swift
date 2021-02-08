import Foundation

extension String {
    var containsWhitespace: Bool {
        self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    }

    /// String with no spaces or new lines in beginning and end.
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    func normalizeNewline() -> String {
        self.replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression, range: nil)
    }
}
