//
//  Skeletonable+UIView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.06.2018.
//  Copyright © 2018 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

private struct AssociatedKey {
    static var skeletonView = "skeletonView"
}

extension UIView: Skeletonable {
    private var skeletonView: SkeletonView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.skeletonView) as? SkeletonView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.skeletonView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func showSkeleton() {
        guard let placeholderView = self.skeleton.viewBuilder() else {
            return
        }

        skeletonView = SkeletonView(placeholderView: placeholderView)
        skeletonView?.show(in: self)
    }

    func hideSkeleton() {
        skeletonView?.hide()
    }
}
