//
//  HorizontalCourseListFlowLayout.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension HorizontalCourseListFlowLayout {
    struct Appearance {
        let pagingVelocityThreshold: CGFloat = 0.6
    }
}

final class HorizontalCourseListFlowLayout: BaseListFlowLayout {
    let appearance: Appearance
    var rowsCount: Int
    var columnsCount: Int

    private var _contentWidth: CGFloat = 0
    override var contentWidth: CGFloat {
        return self._contentWidth
    }

    override var contentHeight: CGFloat {
        let allItemsHeight = self.itemSize.height * CGFloat(self.rowsCount)
        let allSpacing = CGFloat(self.rowsCount + 1) * self.minimumLineSpacing
        return allItemsHeight + allSpacing
    }

    init(rowsCount: Int = 2, columnsCount: Int = 1, appearance: Appearance = Appearance()) {
        self.rowsCount = rowsCount
        self.columnsCount = columnsCount
        self.appearance = appearance
        super.init()
    }

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
        var xOffset: CGFloat = self.minimumInteritemSpacing
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
            cache.append(attributes)

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
            xOffset += self.itemSize.width + 2 * self.minimumInteritemSpacing
        }

        self._contentWidth = xOffset
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
        let velocityThreshold: CGFloat = self.appearance.pagingVelocityThreshold
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
