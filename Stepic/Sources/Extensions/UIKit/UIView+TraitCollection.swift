import UIKit

extension UIView {
    func performBlockIfAppearanceChanged(from previousTraits: UITraitCollection?, block: () -> Void) {
        if #available(iOS 13, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraits) {
                block()
            }
        }
    }

    func performBlockUsingViewTraitCollection(_ block: () -> Void) {
        if #available(iOS 13, *) {
            // Execute the block directly if the traits are the same.
            if self.traitCollection.containsTraits(in: .current) {
                block()
            } else {
                self.traitCollection.performAsCurrent {
                    block()
                }
            }
        } else {
            block()
        }
    }
}
