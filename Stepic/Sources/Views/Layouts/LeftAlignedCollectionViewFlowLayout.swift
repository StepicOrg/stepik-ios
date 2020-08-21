import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = self.sectionInset.left
        var maxY: CGFloat = -1.0

        attributes?.forEach { layoutAttribute in
            // Detect a new line
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = self.sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + self.minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }

        return attributes
    }
}
