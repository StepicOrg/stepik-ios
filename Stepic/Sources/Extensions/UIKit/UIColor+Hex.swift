import UIKit

extension UIColor {
    /// The six-digit hexadecimal representation of color of the form #RRGGBB.
    /// - Parameters:
    ///   - hex6: Six-digit hexadecimal value.
    ///   - alpha: The opacity value of the color object, specified as a value from 0.0 to 1.0.
    ///   Alpha values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0
    convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hex6 & 0x00FF00) >> 8) / divisor
        let blue = CGFloat(hex6 & 0x0000FF) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// The six-digit hexadecimal representation of color with alpha of the form #AARRGGBB.
    /// - Parameter hex8: Eight-digit hexadecimal value.
    convenience init(hex8: UInt32) {
        let divisor = CGFloat(255)
        let alpha = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let red = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let green = CGFloat((hex8 & 0x0000FF00) >> 8) / divisor
        let blue = CGFloat(hex8 & 0x000000FF) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Hex string of a UIColor instance, defaults to black color string #000000.
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let hexString = String(format: "%02X%02X%02X", Int(red * 255.0), Int(green * 255.0), Int(blue * 255.0))

        if alpha < 1 {
            let alphaString = String(format: "%02X", Int(alpha * 255.0))
            return "\(hexString)\(alphaString)"
        }

        return hexString
    }
}
