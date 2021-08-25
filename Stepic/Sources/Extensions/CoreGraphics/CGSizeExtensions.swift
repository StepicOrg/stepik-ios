import Foundation

extension CGSize {
    /// Multiply a CGSize with a scalar.
    ///
    ///     let size = CGSize(width: 1, height: 2)
    ///     let result = size * 3
    ///     // result = CGSize(width: 3, height: 6)
    ///
    /// - Parameters:
    ///   - lhs: CGSize to multiply.
    ///   - scalar: scalar value.
    /// - Returns: The result comes from the multiplication of the given CGSize and scalar.
    static func * (lhs: CGSize, scalar: CGFloat) -> CGSize {
        CGSize(width: lhs.width * scalar, height: lhs.height * scalar)
    }
}
