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
        self.register(SkeletonCollectionViewCell.self, forCellWithReuseIdentifier: SkeletonCollectionViewCell.reuseId)

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

class SkeletonCollectionViewCell: UICollectionViewCell {
    static let reuseId = "SkeletonCollectionViewCell"

    func attach(view: SkeletonView) {
        view.show(in: contentView)
    }
}

class SkeletonCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkeletonCollectionViewCell.reuseId, for: indexPath) as? SkeletonCollectionViewCell else {
            return UICollectionViewCell()
        }

        guard let placeholderCellView = collectionView.skeleton.viewBuilder() else {
            return UICollectionViewCell()
        }

        cell.attach(view: SkeletonView(placeholderView: placeholderCellView))
        return cell
    }
}
