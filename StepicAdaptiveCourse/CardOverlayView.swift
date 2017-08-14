//
//  CardOverlayView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "overlay_simple"
private let overlayLeftImageName = "overlay_hard"

class CardOverlayView: OverlayView {

    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in

        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)

        return imageView
    }()
    @IBOutlet var trailingConstraint: NSLayoutConstraint!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!

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
