//
//  Skeletonable+UICollectionView.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

private struct AssociatedKey {
    static var savedDataSource = "savedDataSource"
    static var skeletonDataSource = "skeletonDataSource"
}

extension UICollectionView {
    private var savedDataSource: UICollectionViewDataSource? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.savedDataSource) as? UICollectionViewDataSource
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.savedDataSource, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var skeletonDataSource: SkeletonCollectionViewDataSource? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.skeletonDataSource) as? SkeletonCollectionViewDataSource
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.skeletonDataSource, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    override func showSkeleton() {
        self.register(cellClass: SkeletonCollectionViewCell.self)

        savedDataSource = self.dataSource
        skeletonDataSource = SkeletonCollectionViewDataSource()

        self.dataSource = skeletonDataSource
        self.reloadData()

        self.isUserInteractionEnabled = false
    }

    override func hideSkeleton() {
        self.dataSource = savedDataSource
        self.reloadData()
        self.isUserInteractionEnabled = true

        skeletonDataSource = nil
    }
}

class SkeletonCollectionViewCell: UICollectionViewCell, Reusable {
    func attach(view: SkeletonView) {
        view.show(in: contentView)
    }
}

class SkeletonCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let flowLayout = collectionView.collectionViewLayout
            as? UICollectionViewFlowLayout else {
            return 20
        }

        var verticalCount = collectionView.bounds.height / flowLayout.itemSize.height
        var horizontalCount = collectionView.bounds.width / flowLayout.itemSize.width

        verticalCount.round(.up)
        horizontalCount.round(.up)

        return Int(verticalCount) * Int(horizontalCount)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SkeletonCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

        guard let placeholderCellView = collectionView.skeleton.viewBuilder() else {
            return UICollectionViewCell()
        }

        cell.attach(view: SkeletonView(placeholderView: placeholderCellView))
        return cell
    }
}
