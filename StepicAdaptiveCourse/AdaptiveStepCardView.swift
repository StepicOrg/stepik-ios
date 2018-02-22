//
//  StepCardView.swift
//  CardsDemo
//
//  Created by Vladislav Kiryukhin on 04.04.17.
//  Copyright © 2017 Vladislav Kiryukhin. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AdaptiveStepCardView: StepCardView {
    @IBOutlet weak var loadingImageView: FLAnimatedImageView!

    override func setupSubviews() {
        super.setupSubviews()
    }

    override func draw(_ rect: CGRect) {
        colorize()

        let gifFile = FileManager.default.contents(atPath: Bundle.main.path(forResource: "loading_robot", ofType: "gif")!)
        loadingImageView.animatedImage = FLAnimatedImage(animatedGIFData: gifFile)
        loadingLabel.text = loadingLabelTexts[Int(arc4random_uniform(UInt32(loadingLabelTexts .count)))]

        if cardPadView == nil {
            backgroundColor = .clear
            layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowOffset = CGSize(width: 0.0, height: 3)
            layer.shadowOpacity = 0.2
            layer.shadowRadius = 4.5

            cardPadView = UIView(frame: bounds)
            cardPadView.backgroundColor = .white
            cardPadView.clipsToBounds = true
            cardPadView.layer.cornerRadius = 10
            insertSubview(cardPadView, at: 0)
        }
    }

    override func colorize() {
        loadingLabel.textColor = UIColor.mainDark
        controlButton.tintColor = UIColor.mainDark
        titleButton.superview?.tintColor = UIColor.mainDark
    }

    enum CardState {
        case loading
        case normal
    }
}
