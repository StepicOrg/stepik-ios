import UIKit

class BounceButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            self.animateBounce()
        }
    }
}
