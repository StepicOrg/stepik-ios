import Foundation

extension String {
    private static let requiredEscapes: Set<Character> = ["<", ">"]
    private static let escapeMap: [Character: String] = [
        "<": "lt",
        ">": "gt"
    ]

    func addingHTMLEntities() -> String {
        var copy = self
        copy.addHTMLEntities()
        return copy
    }

    mutating func addHTMLEntities() {
        var position: String.Index? = self.startIndex

        while let cursorPosition = position {
            guard cursorPosition != self.endIndex else {
                break
            }

            let character = self[cursorPosition]

            if String.requiredEscapes.contains(character), let entity = String.escapeMap[character] {
                let escape = "&\(entity);"
                position = self.positionAfterReplacingCharacter(at: cursorPosition, with: escape)
            } else {
                position = self.index(cursorPosition, offsetBy: 1, limitedBy: self.endIndex)
            }
        }
    }

    /// Replaces the character at the given position with the escape and returns the new position.
    private mutating func positionAfterReplacingCharacter(
        at position: String.Index,
        with escape: String
    ) -> String.Index? {
        let nextIndex = self.index(position, offsetBy: 1)

        if let fittingPosition = self.index(position, offsetBy: escape.count, limitedBy: self.endIndex) {
            // Check if we can fit the whole escape in the receiver
            self.replaceSubrange(position..<nextIndex, with: escape)
            return fittingPosition
        } else {
            // If we can't, remove the character and insert the escape to make it fit.
            self.remove(at: position)
            self.insert(contentsOf: escape, at: position)
            return self.index(position, offsetBy: escape.count, limitedBy: self.endIndex)
        }
    }
}
