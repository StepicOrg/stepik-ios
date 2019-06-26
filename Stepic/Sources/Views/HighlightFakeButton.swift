import Foundation

/// Class to implement highlight (button feedback) by color changing for any UIView
/// Should be used instead of adding gesture recognizer for UIView instance
final class HighlightFakeButton: UIButton {
    var highlightedBackgroundColor = UIColor.white.withAlphaComponent(0.08)
    var defaultBackgroundColor = UIColor.clear

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.backgroundColor = self.highlightedBackgroundColor
            } else {
                self.backgroundColor = self.defaultBackgroundColor
            }
        }
    }
}
