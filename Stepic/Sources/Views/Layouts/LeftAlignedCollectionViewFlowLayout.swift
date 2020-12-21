import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesCopy = NSArray(array: super.layoutAttributesForElements(in: rect) ?? [], copyItems: true)
        let attributes = attributesCopy as? [UICollectionViewLayoutAttributes]

        var leftMargin = self.sectionInset.left
        var maxY: CGFloat = -1.0

        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementKind == UICollectionView.elementKindSectionHeader {
                leftMargin = self.sectionInset.left
                layoutAttribute.frame.size.width -= self.sectionInset.left + self.sectionInset.right
            }

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
