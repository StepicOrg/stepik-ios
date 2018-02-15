//
//  BlurredViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 22.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class BlurredViewController: UIViewController {

    var backgroundImage: UIImage?
    var blurStyle = UIBlurEffectStyle.dark

    override func viewDidLoad() {
        let blurEffect = UIBlurEffect(style: blurStyle)

        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

        view.insertSubview(vibrancyEffectView, at: 0)
        view.insertSubview(blurEffectView, at: 0)

        if let image = backgroundImage {
            let imageView = UIImageView(frame: view.bounds)
            imageView.image = image
            view.insertSubview(imageView, at: 0)
        }
    }
}

class BlurredImageCollectionViewController: UICollectionViewController {

    var backgroundImage: UIImage? = #imageLiteral(resourceName: "background")
    var blurStyle: UIBlurEffectStyle? = UIBlurEffectStyle.extraLight

    override func viewDidLoad() {
        guard let blurStyle = blurStyle else { return }

        let blurEffect = UIBlurEffect(style: blurStyle)

        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

        view.insertSubview(vibrancyEffectView, at: 0)
        view.insertSubview(blurEffectView, at: 0)

        if let image = backgroundImage {
            let imageView = UIImageView(frame: view.bounds)
            imageView.image = image
            view.insertSubview(imageView, at: 0)
        }
    }
}

class BlurredImageNavigationController: UINavigationController {

    var backgroundImage: UIImage? = #imageLiteral(resourceName: "background")
    var blurStyle = UIBlurEffectStyle.extraLight

    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: blurStyle)

        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

        view.insertSubview(vibrancyEffectView, at: 0)
        view.insertSubview(blurEffectView, at: 0)

        if let image = backgroundImage {
            let imageView = UIImageView(frame: view.bounds)
            imageView.image = image
            view.insertSubview(imageView, at: 0)
        }
    }
}
