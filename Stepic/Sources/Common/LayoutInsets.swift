import UIKit

struct LayoutInsets {
    static let `default` = LayoutInsets(inset: 16)

    private let topInset: CGFloat?
    private let leftInset: CGFloat?
    private let rightInset: CGFloat?
    private let bottomInset: CGFloat?

    var top: CGFloat {
        guard let value = self.topInset else {
            fatalError("Top inset is undefined")
        }
        return value
    }

    var left: CGFloat {
        guard let value = self.leftInset else {
            fatalError("Left inset is undefined")
        }
        return value
    }

    var right: CGFloat {
        guard let value = self.rightInset else {
            fatalError("Right inset is undefined")
        }
        return value
    }

    var bottom: CGFloat {
        guard let value = self.bottomInset else {
            fatalError("Bottom inset is undefined")
        }
        return value
    }

    init(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        self.topInset = top
        self.leftInset = left
        self.rightInset = right
        self.bottomInset = bottom
    }

    init(insets: UIEdgeInsets) {
        self.topInset = insets.top
        self.leftInset = insets.left
        self.rightInset = insets.right
        self.bottomInset = insets.bottom
    }

    init(inset: CGFloat) {
        self.topInset = inset
        self.leftInset = inset
        self.rightInset = inset
        self.bottomInset = inset
    }

    init(horizontal: CGFloat) {
        self.topInset = nil
        self.leftInset = horizontal
        self.rightInset = horizontal
        self.bottomInset = nil
    }

    init(vertical: CGFloat) {
        self.topInset = vertical
        self.leftInset = nil
        self.rightInset = nil
        self.bottomInset = vertical
    }
}
