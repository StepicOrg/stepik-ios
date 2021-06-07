import UIKit

private enum Animation {
    static let bounceDuration: TimeInterval = 0.15
    static let bounceScale: CGFloat = 0.95
}

extension UIView {
    func animateBounce(
        withDuration duration: TimeInterval = Animation.bounceDuration,
        bounceScale scale: CGFloat = Animation.bounceScale,
        isScaled: Bool
    ) {
        UIView.animate(withDuration: duration) {
            self.transform = isScaled
                ? CGAffineTransform(scaleX: scale, y: scale)
                : .identity
        }
    }
}

extension UIControl {
    func animateBounce(
        withDuration duration: TimeInterval = Animation.bounceDuration,
        bounceScale scale: CGFloat = Animation.bounceScale
    ) {
        self.animateBounce(withDuration: duration, bounceScale: scale, isScaled: self.isHighlighted)
    }
}
