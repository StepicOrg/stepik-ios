//
//  PlaceholderTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SkeletonView

class PlaceholderTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var placeholderView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        placeholderView.isSkeletonable = true
    }

    func startAnimating() {
        placeholderView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.mainLight),
                                                     animation: GradientDirection.leftRight.slidingAnimation())
    }
}
