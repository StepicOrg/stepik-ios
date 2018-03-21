//
//  BlurredView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 30.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class BlurredView: UIView {

    var backgroundImage: UIImage?
    var blurStyle = UIBlurEffectStyle.extraLight

    private var blurEffectView: UIVisualEffectView!
    private var vibrancyEffectView: UIVisualEffectView!

    init(frame: CGRect, style: UIBlurEffectStyle, image: UIImage? = nil) {
        super.init(frame: frame)

        backgroundImage = image
        blurStyle = style
        addSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func addSubviews() {
        let blurEffect = UIBlurEffect(style: blurStyle)

        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

        self.insertSubview(vibrancyEffectView, at: 0)
        self.insertSubview(blurEffectView, at: 0)

        if let image = backgroundImage {
            let imageView = UIImageView(frame: self.bounds)
            imageView.image = image
            self.insertSubview(imageView, at: 0)
        }
    }

}
