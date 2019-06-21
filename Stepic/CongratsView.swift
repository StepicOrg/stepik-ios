//
//  CongratsView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CongratsView: UIView {
    let backgroundAnimationColor: UIColor = UIColor.white.withAlphaComponent(0.3)
    let backgroundSectionsCount: Int = 18
    let padOpacity: CGFloat = 0.15

    struct AnimationDuration {
        static let hiding: TimeInterval = 0.5
        static let backgroundRotate: TimeInterval = 30.0
    }

    private var blurView: UIVisualEffectView?
    private var padView: UIView?
    private var shapeLayer: CAShapeLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Blur
        padView = UIView(frame: bounds)
        padView?.backgroundColor = .black
        padView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(padView ?? UIView())

        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView?.frame = bounds
        blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView ?? UIView())

        // Background animation
        let path: CGMutablePath = CGMutablePath()

        // colors and clears sections
        shapeLayer = CAShapeLayer()
        let angle = Double.pi / (Double(backgroundSectionsCount) / 2)
        for i in 1...backgroundSectionsCount {
            if i % 2 == 0 {
                let startAngle = angle * Double(i)
                let endAngle = startAngle + angle

                path.move(to: CGPoint(x: 0.0, y: 0.0))
                path.addArc(center: CGPoint(x: 0.0, y: 0.0), radius: frame.height + frame.width, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: false)
                path.closeSubpath()
            }
        }

        shapeLayer?.position = CGPoint(x: center.x, y: center.y)
        shapeLayer?.path = path
        shapeLayer?.fillColor = backgroundAnimationColor.cgColor
        shapeLayer?.isHidden = false
        layer.addSublayer(shapeLayer ?? CAShapeLayer())

        // Add rotation
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 2 * Double.pi
        animation.duration = AnimationDuration.backgroundRotate
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.fillMode = CAMediaTimingFillMode.forwards
        shapeLayer?.add(animation, forKey: animation.keyPath)

        padView?.alpha = padOpacity
        blurView?.alpha = 1.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shapeLayer?.position = CGPoint(x: center.x, y: center.y)
    }
}
