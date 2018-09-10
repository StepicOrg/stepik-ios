//
//  VerticalCourseListFlowLayout.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension VerticalCourseListFlowLayout {
    struct Appearance {
        let paginationViewHeight: CGFloat = 65
    }
}

final class VerticalCourseListFlowLayout: BaseListFlowLayout {
    let appearance: Appearance
    var columnsCount: Int

    private var previousPaginationViewSize: CGSize?
    private var previousAllItemsOffset: CGFloat?

    override var contentWidth: CGFloat {
        let allItemsWidth = self.itemSize.width * CGFloat(self.columnsCount)
        let flowInsets = 2 * self.minimumInteritemSpacing
        return allItemsWidth + flowInsets
    }

    private var _contentHeight: CGFloat = 0
    override var contentHeight: CGFloat {
        return _contentHeight
    }

    var isPaginationEnabled = false {
        didSet {
            if oldValue != self.isPaginationEnabled {
                self.updatePaginationViewSizeInCache()
                self.invalidateLayout()
            }
        }
    }

    private var paginationSize: CGSize {
        let viewSize = CGSize(
            width: self.collectionView?.bounds.width ?? 0,
            height: self.appearance.paginationViewHeight
        )
        return self.isPaginationEnabled ? viewSize : .zero
    }

    init(columnsCount: Int = 1, appearance: Appearance = Appearance()) {
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

        guard let collectionView = collectionView else {
            return
        }

        var xOffset = self.minimumInteritemSpacing
        var yOffset = self.minimumLineSpacing
        var columnIndex = 0

        // Convert multiple sections into one
        var flatIndexPaths: [IndexPath] = []
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                flatIndexPaths.append(IndexPath(item: item, section: section))
            }
        }

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

            if columnIndex < self.columnsCount - 1 {
                xOffset += self.itemSize.width + self.minimumInteritemSpacing
                columnIndex += 1
            } else {
                columnIndex = 0
                xOffset = self.minimumInteritemSpacing
                yOffset += self.itemSize.height + self.minimumLineSpacing
            }
        }

        if columnIndex > 0 {
            yOffset += self.itemSize.height + self.minimumLineSpacing
        }

        self.previousAllItemsOffset = yOffset
        self._contentHeight = yOffset

        self.updatePaginationViewSizeInCache()
    }

    private func updatePaginationViewSizeInCache() {
        guard let collectionView = self.collectionView,
              let contentOffset = self.previousAllItemsOffset else {
            return
        }

        // Remove old attributes
        for i in 0..<self.cache.count {
            if self.cache[i].representedElementKind == UICollectionElementKindSectionFooter {
                self.cache.remove(at: i)
                break
            }
        }

        guard self.isPaginationEnabled else {
            self._contentHeight = contentOffset
            return
        }

        let paginationSupplementaryViewAttributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
            with: IndexPath(
                item: 0,
                section: collectionView.numberOfSections - 1
            )
        )

        paginationSupplementaryViewAttributes.frame = CGRect(
            x: 0,
            y: contentOffset,
            width: self.paginationSize.width,
            height: self.paginationSize.height
        )

        self.cache.append(paginationSupplementaryViewAttributes)
        self._contentHeight = contentOffset
            + self.minimumLineSpacing
            + self.paginationSize.height
    }
}
