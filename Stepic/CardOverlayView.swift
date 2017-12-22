//
//  CardOverlayView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Koloda

class CardOverlayView: OverlayView {

    private let overlayRightImageName = "overlay_simple"
    private let overlayLeftImageName = "overlay_hard"

    lazy var overlayImageView: UIImageView! = { [unowned self] in
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        imageView.constrainWidth("180")
        imageView.constrainHeight("180")
        imageView.constrainTopSpace(toView: self, predicate: "10")
        self.leadingConstraint = imageView.constrainLeadingSpace(toView: self, predicate: "10")
        self.trailingConstraint = imageView.constrainTrailingSpace(toView: self, predicate: "10")
        self.trailingConstraint.isActive = false

        return imageView
    }()

    var trailingConstraint: NSLayoutConstraint!
    var leadingConstraint: NSLayoutConstraint!

    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)

                leadingConstraint.isActive = false
                trailingConstraint.isActive = true
                leadingConstraint.constant = 10
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)

                leadingConstraint.isActive = true
                trailingConstraint.isActive = false
                trailingConstraint.constant = 10
            default:
                overlayImageView.image = nil
            }

        }
    }

}
