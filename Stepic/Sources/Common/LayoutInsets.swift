import UIKit

struct LayoutInsets {
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
}
