import UIKit

extension HorizontalCourseListFlowLayout {
    enum Paging {
        static let velocityThreshold: CGFloat = 0.6
    }

    struct Appearance {
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let paginationViewWidth: CGFloat = 100
    }
}

final class HorizontalCourseListFlowLayout: BaseListFlowLayout {
    let appearance: Appearance
    var rowsCount: Int
    var columnsCount: Int

    private var _contentWidth: CGFloat = 0
    override var contentWidth: CGFloat { self._contentWidth }

    override var contentHeight: CGFloat {
        let allItemsHeight = self.itemSize.height * CGFloat(self.rowsCount)
        let allSpacing = CGFloat(self.rowsCount + 1) * self.minimumLineSpacing
        return allItemsHeight + allSpacing
    }

    var isPaginationHidden = true {
        didSet {
            if oldValue != self.isPaginationHidden {
                self.cache.removeAll(keepingCapacity: true)
                self.invalidateLayout()
            }
        }
    }

    private var paginationSize: CGSize {
        let viewSize = CGSize(
            width: self.appearance.paginationViewWidth,
            height: self.collectionView?.bounds.height ?? 0
        )
        return self.isPaginationHidden ? .zero : viewSize
    }

    init(
        rowsCount: Int = 2,
        columnsCount: Int = 1,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.rowsCount = rowsCount
        self.columnsCount = columnsCount
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        guard self.cache.isEmpty else {
            return
        }

        guard let collectionView = self.collectionView else {
            return
        }

        // Convert multiple sections into one
        var flatIndexPaths: [IndexPath] = []
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                flatIndexPaths.append(IndexPath(item: item, section: section))
            }
        }

        var yOffset: CGFloat = self.minimumLineSpacing
        var xOffset: CGFloat = self.appearance.insets.left
        var rowIndex = 0

        for indexPath in flatIndexPaths {
            let frame = CGRect(
                x: xOffset,
                y: yOffset,
                width: self.itemSize.width,
                height: self.itemSize.height
            )

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            self.cache.append(attributes)

            if rowIndex < self.rowsCount - 1 {
                yOffset += self.itemSize.height + self.minimumLineSpacing
                rowIndex += 1
            } else {
                rowIndex = 0
                yOffset = self.minimumLineSpacing
                xOffset += self.itemSize.width + self.minimumInteritemSpacing
            }
        }

        if rowIndex > 0 {
            xOffset += self.itemSize.width + self.minimumInteritemSpacing
        }

        // Footer
        let paginationSupplementaryViewAttributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            with: IndexPath(
                item: 0,
                section: collectionView.numberOfSections - 1
            )
        )

        paginationSupplementaryViewAttributes.frame = CGRect(
            x: xOffset,
            y: 0,
            width: self.paginationSize.width,
            height: self.paginationSize.height
        )

        self.cache.append(paginationSupplementaryViewAttributes)

        xOffset += self.appearance.insets.right - self.minimumInteritemSpacing

        self._contentWidth = xOffset
            + self.paginationSize.width
            + (self.paginationSize.width > 0 ? self.minimumInteritemSpacing : 0)
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
