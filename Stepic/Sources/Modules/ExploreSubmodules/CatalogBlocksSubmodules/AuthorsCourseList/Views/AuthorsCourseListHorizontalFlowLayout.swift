import UIKit

extension AuthorsCourseListHorizontalFlowLayout {
    enum Paging {
        static let velocityThreshold: CGFloat = 0.6
    }

    struct Appearance {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

final class AuthorsCourseListHorizontalFlowLayout: UICollectionViewFlowLayout {
    let appearance: Appearance

    var rowsCount: Int
    var columnsCount: Int

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
    private var contentHeight: CGFloat {
        let verticalSectionInsets = self.sectionInset.top + self.sectionInset.bottom
        let allItemsHeight = self.itemSize.height * CGFloat(self.rowsCount)
        let allSpacing = CGFloat(self.rowsCount + 1) * self.minimumLineSpacing
        return verticalSectionInsets + allItemsHeight + allSpacing
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: self.contentWidth, height: self.contentHeight)
    }

    init(
        rowsCount: Int = 1,
        columnsCount: Int = 1,
        appearance: Appearance = Appearance()
    ) {
        self.rowsCount = rowsCount
        self.columnsCount = columnsCount
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

        var yOffset: CGFloat = self.sectionInset.top
        var xOffset: CGFloat = self.sectionInset.left
        var rowIndex = 0

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

            if rowIndex < self.rowsCount - 1 {
                yOffset += self.itemSize.height + self.minimumLineSpacing
                rowIndex += 1
            } else {
                rowIndex = 0
                yOffset = self.sectionInset.top
                xOffset += self.itemSize.width + self.minimumInteritemSpacing
            }
        }

        if rowIndex > 0 {
            xOffset += self.itemSize.width + self.minimumInteritemSpacing
        }

        xOffset += self.appearance.insets.right - self.minimumInteritemSpacing + self.sectionInset.right

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
