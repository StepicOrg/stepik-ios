//
//  PlaceholderTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class PlaceholderTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        let margin = CGFloat(arc4random()) / CGFloat(UInt32.max) * 20.0
        self.rightConstraint.constant = CGFloat(margin)
    }

    override func colorize() {
        super.colorize()
        self.placeholderView.backgroundColor = .clear
    }

    func startAnimating() {
        self.placeholderView.skeleton.viewBuilder = { UIView.fromNib(named: "ProfileCellSkeletonPlaceholderView") }
        self.placeholderView.skeleton.show()
    }
}
