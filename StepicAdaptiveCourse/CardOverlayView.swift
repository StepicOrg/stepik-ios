//
//  CardOverlayView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "overlay_hard"
private let overlayLeftImageName = "overlay_simple"

class CardOverlayView: OverlayView {
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
    }()
    
    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
                overlayImageView.contentMode = .topRight
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
                overlayImageView.contentMode = .topLeft
            default:
                overlayImageView.image = nil
            }
            
        }
    }

}
