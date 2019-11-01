import Foundation

extension NSAttributedString {
    public func trimmingCharacters(in set: CharacterSet) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        mutableAttributedString.trimCharacters(in: set)
        return NSAttributedString(attributedString: mutableAttributedString)
    }
}

extension NSMutableAttributedString {
    public func trimCharacters(in set: CharacterSet) {
        var range = (self.string as NSString).rangeOfCharacter(from: set)

        // Trim leading characters from character set.
        while range.length != 0 && range.location == 0 {
            self.replaceCharacters(in: range, with: "")
            range = (self.string as NSString).rangeOfCharacter(from: set)
        }

        // Trim trailing characters from character set.
        range = (self.string as NSString).rangeOfCharacter(from: set, options: .backwards)
        while range.length != 0 && NSMaxRange(range) == self.length {
            self.replaceCharacters(in: range, with: "")
            range = (self.string as NSString).rangeOfCharacter(from: set, options: .backwards)
        }
    }
}
