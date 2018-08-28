//
//  BaseCourseListFlowLayout.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class BaseListFlowLayout: UICollectionViewFlowLayout {
    private var previousSize: CGSize?
    var cache: [UICollectionViewLayoutAttributes] = []

    var shouldInvalidateAttributesCache: Bool {
        if self.previousSize != self.collectionView?.bounds.size {
            self.previousSize = self.collectionView?.bounds.size
            return true
        }
        return false
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
