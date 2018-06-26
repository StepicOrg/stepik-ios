//
//  PlaceholderTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class PlaceholderTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        let margin = CGFloat(arc4random()) / CGFloat(UInt32.max) * 20.0
        rightConstraint.constant = CGFloat(margin)
    }

    func startAnimating() {
        placeholderView.skeleton.viewBuilder = { return UIView.fromNib(named: "ProfileCellSkeletonPlaceholderView") }
        placeholderView.skeleton.show()
    }
}
