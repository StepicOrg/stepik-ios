import UIKit

extension UIFont {
    func sizeOfString(string: String, constrainedToWidth width: Double) -> CGSize {
        NSString(string: string).boundingRect(
            with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: self],
            context: nil
        ).size
    }
}
