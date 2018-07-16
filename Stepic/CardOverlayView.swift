//
//  CardOverlayView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Koloda
import SnapKit

class CardOverlayView: OverlayView {

    private let overlayRightImageName = "overlay_simple"
    private let overlayLeftImageName = "overlay_hard"

    private var trailingConstraint: Constraint!
    private var leadingConstraint: Constraint!

    lazy var overlayImageView: UIImageView! = {
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(180)
            make.top.equalTo(self).offset(10)
            self.leadingConstraint = make.leading.equalTo(self).offset(10).constraint
            self.trailingConstraint = make.trailing.equalTo(self).offset(-10).constraint
        }
        self.trailingConstraint.deactivate()

        return imageView
    }()

    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)

                leadingConstraint.deactivate()
                trailingConstraint.activate()
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)

                leadingConstraint.activate()
                trailingConstraint.deactivate()
            default:
                overlayImageView.image = nil
            }

        }
    }

}
