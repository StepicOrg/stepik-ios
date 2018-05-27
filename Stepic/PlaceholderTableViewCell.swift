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
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        placeholderView.isSkeletonable = true

        let margin = Double(arc4random()) / 0xFFFFFFFF * 20.0
        rightConstraint.constant = rightConstraint.constant + CGFloat(margin)
    }

    func startAnimating() {
        placeholderView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.mainLight),
                                                     animation: GradientDirection.leftRight.slidingAnimation())
    }
}
