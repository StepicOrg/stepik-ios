//
//  UICollectionViewFlowLayout+PlusCrashWorkaround.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

extension UICollectionViewFlowLayout {
    func setEstimatedItemSize(_ size: CGSize, fallbackOnPlus fallbackSize: CGSize) {
        if DeviceInfo.current.OSVersion.major == 10 && DeviceInfo.current.isPlus {
            // Workaround for crash on iPhone Plus & iOS 10
            self.estimatedItemSize = CGSize.zero
            self.itemSize = fallbackSize
        } else {
            self.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
        }
    }
}
