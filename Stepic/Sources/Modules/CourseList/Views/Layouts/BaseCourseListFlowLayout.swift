import UIKit

class BaseListFlowLayout: UICollectionViewFlowLayout {
    private var previousSize: CGSize?
    private var previousItemsCount = 0
    var cache: [UICollectionViewLayoutAttributes] = []

    var shouldInvalidateAttributesCache: Bool {
        guard let collectionView = self.collectionView else {
            return true
        }

        var count = 0
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                count += 1
            }
        }

        defer {
            self.previousItemsCount = count
            self.previousSize = self.collectionView?.bounds.size
        }
        return self.previousItemsCount != count
            || self.previousSize != self.collectionView?.bounds.size
    }

    var contentWidth: CGFloat {
        return 0
    }

    var contentHeight: CGFloat {
        return 0
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }

    override func prepare() {
        super.prepare()

        if self.shouldInvalidateAttributesCache {
            self.cache.removeAll(keepingCapacity: true)
        }
    }

    // swiftlint:disable:next discouraged_optional_collection
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in self.cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
}
