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
    @IBOutlet weak var loadingSecondaryButtonView: UIView!
    @IBOutlet weak var loadingSubtitleView: UIView!

    override var nibName: String {
        return "LoadingCourseWidgetView"
    }

    private var gradientLayer: CAGradientLayer?
    var isAnimating: Bool = false {
        didSet {
            if isAnimating && !oldValue {
                setupGradient()
                updateGradient()

                guard let gradientLayer = self.gradientLayer else {
                    return
                }

                let gradientAnimation = CABasicAnimation(keyPath: "locations")
                gradientAnimation.fromValue = gradientLayer.locations
                gradientAnimation.toValue = [0.9, 1.1, 1.2]
                gradientAnimation.duration = 3.0
                gradientAnimation.fillMode = kCAFillModeForwards
                gradientAnimation.repeatCount = .infinity
                gradientLayer.add(gradientAnimation, forKey: nil)
            }
            if !isAnimating && oldValue {
                gradientLayer?.removeAllAnimations()
            }
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        setupGradient()
        updateGradient()
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

    private func add(loadingView: UIView, toPath path: UIBezierPath) {
        path.append(UIBezierPath(roundedRect: loadingView.frame, cornerRadius: 8))
    }

    private func updateGradient() {
        guard let gradientLayer = self.gradientLayer else {
            return
        }

        // Update frame
        gradientLayer.frame = view.bounds

        // Update mask
        let path = UIBezierPath()
        add(loadingView: loadingImageView, toPath: path)
        add(loadingView: loadingTitleView, toPath: path)
        add(loadingView: loadingSubtitleView, toPath: path)
        add(loadingView: loadingStatsView, toPath: path)
        add(loadingView: loadingButtonView, toPath: path)
        add(loadingView: loadingSecondaryButtonView, toPath: path)
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.path = path.cgPath
        gradientLayer.mask = maskLayer
    }

    private func setRoundLoading(view: UIView) {
        view.setRoundedCorners(cornerRadius: 8)
        view.backgroundColor = UIColor.mainLight
    }

    override func setupSubviews() {
        setRoundLoading(view: loadingImageView)
        setRoundLoading(view: loadingTitleView)
        setRoundLoading(view: loadingSecondaryButtonView)
        setRoundLoading(view: loadingButtonView)
        setRoundLoading(view: loadingStatsView)
        setRoundLoading(view: loadingSubtitleView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        view.layoutIfNeeded()
        updateGradient()
    }

}
