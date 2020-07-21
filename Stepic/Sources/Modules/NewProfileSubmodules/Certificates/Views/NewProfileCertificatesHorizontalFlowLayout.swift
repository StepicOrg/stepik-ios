import UIKit

extension NewProfileCertificatesHorizontalFlowLayout {
    enum Paging {
        static let velocityThreshold: CGFloat = 0.6
    }

    struct Appearance {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

final class NewProfileCertificatesHorizontalFlowLayout: UICollectionViewFlowLayout {
    let appearance: Appearance

    private var previousSize: CGSize?
    private var previousItemsCount = 0
    private var cache: [UICollectionViewLayoutAttributes] = []

    private var shouldInvalidateAttributesCache: Bool {
        guard let collectionView = self.collectionView else {
            return true
        }

        let count = collectionView.numberOfItems(inSection: 0)

        defer {
            self.previousItemsCount = count
            self.previousSize = self.collectionView?.bounds.size
        }

        return self.previousItemsCount != count
            || self.previousSize != self.collectionView?.bounds.size
    }

    private var contentWidth: CGFloat = 0

    override var collectionViewContentSize: CGSize {
        CGSize(width: self.contentWidth, height: self.itemSize.height)
    }

    init(appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        if self.shouldInvalidateAttributesCache {
            self.cache.removeAll(keepingCapacity: true)
        }

        guard self.cache.isEmpty else {
            return
        }

        guard let collectionView = self.collectionView else {
            return
        }

        var yOffset: CGFloat = self.minimumLineSpacing
        var xOffset: CGFloat = 0

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let frame = CGRect(
                x: xOffset,
                y: yOffset,
                width: self.itemSize.width,
                height: self.itemSize.height
            )

            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
            attributes.frame = frame
            self.cache.append(attributes)

            yOffset = self.minimumLineSpacing
            xOffset += self.itemSize.width + self.minimumInteritemSpacing
        }

        xOffset += self.appearance.insets.right - self.minimumInteritemSpacing

        self.contentWidth = xOffset
    }

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

    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }

        let pageWidth = self.itemSize.width + self.minimumInteritemSpacing
        let currentPage: CGFloat = collectionView.contentOffset.x / pageWidth
        let nearestPage: CGFloat = round(currentPage)

        var pageDiff: CGFloat = 0
        let velocityThreshold: CGFloat = Paging.velocityThreshold
        if nearestPage < currentPage {
            if velocity.x >= velocityThreshold {
                pageDiff = 1
            }
        } else {
            if velocity.x <= -velocityThreshold {
                pageDiff = -1
            }
        }

        let x = (nearestPage + pageDiff) * pageWidth
        return CGPoint(x: max(0, x), y: proposedContentOffset.y)
    }
}
