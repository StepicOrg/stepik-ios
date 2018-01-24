//
//  BlurredViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 22.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class BlurredViewController: UIViewController {

    var blurStyle = UIBlurEffectStyle.dark

    override func viewDidLoad() {
        let blurEffect = UIBlurEffect(style: blurStyle)

        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

        view.insertSubview(vibrancyEffectView, at: 0)
        view.insertSubview(blurEffectView, at: 0)
        /*
        view.addSubview(blurEffectView)
        view.addSubview(vibrancyEffectView)
 */
    }
}
