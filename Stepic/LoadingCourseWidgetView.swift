//
//  LoadingCourseWidgetView.swift
//  Stepic
//
//  Created by Ostrenkiy on 15.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import FLKAutoLayout

class LoadingCourseWidgetView: NibInitializableView {

    @IBOutlet weak var loadingImageView: UIView!
    @IBOutlet weak var loadingTitleView: UIView!
    @IBOutlet weak var loadingStatsView: UIView!
    @IBOutlet weak var loadingButtonView: UIView!

    override var nibName: String {
        return "LoadingCourseWidgetView"
    }

    private var gradientLayer: CAGradientLayer?
    private var isAnimating: Bool = false

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        setupGradient()
        updateGradient()
        animateGradient()
    }

    private func setupGradient() {
        if gradientLayer != nil { return }

        gradientLayer = CAGradientLayer()

        guard let gradientLayer = self.gradientLayer else {
            return
        }

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        gradientLayer.locations = [-0.2, -0.1, 0.0]

        layer.insertSublayer(gradientLayer, at: UInt32.max)
    }

    private func updateGradient() {
        guard let gradientLayer = self.gradientLayer else {
            return
        }

        // Update frame
        gradientLayer.frame = view.bounds

        // Update mask
        let path = UIBezierPath()
        path.append(UIBezierPath(roundedRect: loadingImageView.frame, cornerRadius: 8))
        path.append(UIBezierPath(roundedRect: loadingTitleView.frame, cornerRadius: 8))
        path.append(UIBezierPath(roundedRect: loadingStatsView.frame, cornerRadius: 8))
        path.append(UIBezierPath(roundedRect: loadingButtonView.frame, cornerRadius: 8))

        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.path = path.cgPath
        gradientLayer.mask = maskLayer
    }

    private func animateGradient() {
        if isAnimating { return }

        guard let gradientLayer = self.gradientLayer else {
            return
        }

        isAnimating = true

        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = gradientLayer.locations
        gradientAnimation.toValue = [0.9, 1.1, 1.2]
        gradientAnimation.duration = 3.0
        gradientAnimation.fillMode = kCAFillModeForwards
        gradientAnimation.repeatCount = .infinity
        gradientLayer.add(gradientAnimation, forKey: nil)
    }

    override func setupSubviews() {
        loadingImageView.setRoundedCorners(cornerRadius: 8)
        loadingImageView.backgroundColor = UIColor.mainLight
        loadingTitleView.setRoundedCorners(cornerRadius: 8)
        loadingTitleView.backgroundColor = UIColor.mainLight
        loadingStatsView.setRoundedCorners(cornerRadius: 8)
        loadingStatsView.backgroundColor = UIColor.mainLight
        loadingButtonView.setRoundedCorners(cornerRadius: 8)
        loadingButtonView.backgroundColor = UIColor.mainLight
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        view.layoutIfNeeded()
        updateGradient()
    }

}
