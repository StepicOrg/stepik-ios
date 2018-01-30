//
//  BlurredView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 30.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class BlurredView: UIView {

    var blurStyle = UIBlurEffectStyle.light

    private var blurEffectView: UIVisualEffectView!
    private var vibrancyEffectView: UIVisualEffectView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    private func addSubviews() {
        let blurEffect = UIBlurEffect(style: blurStyle)

        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

        self.insertSubview(vibrancyEffectView, at: 0)
        self.insertSubview(blurEffectView, at: 0)
    }

}
