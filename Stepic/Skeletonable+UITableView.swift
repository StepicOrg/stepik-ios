//
//  Skeletonable+UITableView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.06.2018.
//  Copyright © 2018 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

private struct AssociatedKey {
    static var savedDataSource = "savedDataSource"
    static var skeletonDataSource = "skeletonDataSource"
}

extension UITableView {
    private var savedDataSource: UITableViewDataSource? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.savedDataSource) as? UITableViewDataSource
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.savedDataSource, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var skeletonDataSource: SkeletonTableViewDataSource? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.skeletonDataSource) as? SkeletonTableViewDataSource
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.skeletonDataSource, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    override func showSkeleton() {
        self.register(SkeletonTableViewCell.self, forCellReuseIdentifier: SkeletonTableViewCell.reuseId)

        savedDataSource = self.dataSource
        skeletonDataSource = SkeletonTableViewDataSource()

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

class SkeletonTableViewCell: UITableViewCell {
    static let reuseId = "SkeletonTableViewCell"

    func attach(view: SkeletonView) {
        view.show(in: contentView)
    }
}

class SkeletonTableViewDataSource: NSObject, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(max(tableView.bounds.width, tableView.bounds.height) / 44.0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonTableViewCell.reuseId, for: indexPath) as? SkeletonTableViewCell else {
            return UITableViewCell()
        }

        guard let placeholderCellView = tableView.skeleton.viewBuilder() else {
            return UITableViewCell()
        }

        cell.attach(view: SkeletonView(placeholderView: placeholderCellView))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
