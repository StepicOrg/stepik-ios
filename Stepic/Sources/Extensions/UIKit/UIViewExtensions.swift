import UIKit

extension UIView {
    /// Add array of subviews to view.
    ///
    /// - Parameter subviews: array of subviews to add to self.
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { self.addSubview($0) }
    }

    /// Set some or all corners radiuses of view.
    ///
    /// - Parameters:
    ///   - corners: array of corners to change (example: [.bottomLeft, .topRight]).
    ///   - radius: radius for selected corners.
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if corners.contains(.allCorners) {
            self.roundAllCorners(radius: radius)
        } else {
            let maskPath = UIBezierPath(
                roundedRect: self.bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )

            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            self.layer.mask = shape

            self.layer.masksToBounds = true
            self.clipsToBounds = true
        }
    }

    func roundAllCorners(radius: CGFloat, borderWidth: CGFloat? = nil, borderColor: UIColor? = nil ) {
        self.layer.cornerRadius = radius

        if let borderWidth = borderWidth {
            self.layer.borderWidth = borderWidth
        }

        if let borderColor = borderColor {
            self.layer.borderColor = borderColor.cgColor
        }

        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func roundBounds(width: CGFloat, color: UIColor = UIColor.white) {
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
}
