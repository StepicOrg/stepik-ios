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
        let headerViewHeight: CGFloat = 104
        let paginationViewHeight: CGFloat = 52
    }
}

final class VerticalCourseListFlowLayout: BaseListFlowLayout {
    let appearance: Appearance
    var columnsCount: Int

    override var contentWidth: CGFloat {
        let allItemsWidth = self.itemSize.width * CGFloat(self.columnsCount)
        let flowInsets = 2 * self.minimumInteritemSpacing
        return allItemsWidth + flowInsets
    }

    private var _contentHeight: CGFloat = 0
    override var contentHeight: CGFloat {
        return _contentHeight
    }

    var isPaginationHidden = true {
        didSet {
            if oldValue != self.isPaginationHidden {
                self.cache.removeAll(keepingCapacity: true)
                self.invalidateLayout()
            }
        }
    }

    let isHeaderHidden: Bool

    private var paginationSize: CGSize {
        let viewSize = CGSize(
            width: self.collectionView?.bounds.width ?? 0,
            height: self.appearance.paginationViewHeight
        )
        return self.isPaginationHidden ? .zero : viewSize
    }

    private var headerSize: CGSize {
        let viewSize = CGSize(
            width: self.collectionView?.bounds.width ?? 0,
            height: self.appearance.headerViewHeight
        )
        return self.isHeaderHidden ? .zero : viewSize
    }

    init(
        columnsCount: Int = 1,
        isHeaderHidden: Bool = true,
        appearance: Appearance = Appearance()
    ) {
        self.columnsCount = columnsCount
        self.isHeaderHidden = isHeaderHidden
        self.appearance = appearance
        super.init()
        self.scrollDirection = .vertical
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

        // Header
        let headerSupplementaryViewAttributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            with: IndexPath(
                item: 0,
                section: collectionView.numberOfSections - 1
            )
        )

        headerSupplementaryViewAttributes.frame = CGRect(
            x: 0,
            y: 0,
            width: self.headerSize.width,
            height: self.headerSize.height
        )

        self.cache.append(headerSupplementaryViewAttributes)

        // Items
        var xOffset = self.minimumInteritemSpacing
        var yOffset = self.headerSize.height + self.minimumLineSpacing
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
            self.cache.append(attributes)

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

        // Footer
        let paginationSupplementaryViewAttributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
            with: IndexPath(
                item: 0,
                section: collectionView.numberOfSections - 1
            )
        )

        paginationSupplementaryViewAttributes.frame = CGRect(
            x: 0,
            y: yOffset,
            width: self.paginationSize.width,
            height: self.paginationSize.height
        )

        self.cache.append(paginationSupplementaryViewAttributes)

        self._contentHeight = yOffset
            + self.paginationSize.height
            + (self.paginationSize.height > 0 ? self.minimumLineSpacing : 0)
    }
}
