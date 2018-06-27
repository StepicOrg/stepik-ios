//
//  Skeletonable.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.06.2018.
//  Copyright © 2018 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

private struct AssociatedKey {
    static var skeleton = "skeleton"
}

// Proxy class to hide UIView implementation
class Skeleton {
    private var parent: Skeletonable

    var viewBuilder: (() -> UIView?) = {
        return nil
    }

    init(parent: Skeletonable) {
        self.parent = parent
    }

    func show() {
        parent.showSkeleton()
    }

    func hide() {
        parent.hideSkeleton()
    }
}

@objc protocol Skeletonable {
    @objc func showSkeleton()
    @objc func hideSkeleton()
}

extension Skeletonable {
    var skeleton: Skeleton {
        if let skeleton = objc_getAssociatedObject(self, &AssociatedKey.skeleton) as? Skeleton {
            return skeleton
        }

        let skeleton = Skeleton(parent: self)
        objc_setAssociatedObject(self, &AssociatedKey.skeleton, skeleton, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return skeleton
    }
}
