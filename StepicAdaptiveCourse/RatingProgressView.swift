//
//  RatingProgressView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class RatingProgressView: UIView {
    @IBInspectable var mainColor: UIColor? = UIColor(red: 0, green: 128 / 255, blue: 128 / 255, alpha: 1.0)
    @IBInspectable var congratulationColor: UIColor? = UIColor(red: 0, green: 128 / 255, blue: 64 / 255, alpha: 1.0)
    @IBInspectable var backLabelColor: UIColor? = UIColor.darkGray.withAlphaComponent(0.6)
    @IBInspectable var frontLabelColor: UIColor? = UIColor.white
    @IBInspectable var congratulationLabelColor: UIColor? = UIColor.white
    @IBInspectable var labelFont: UIFont? = UIFont.systemFont(ofSize: 15)
    
    struct AnimationDuration {
        static let progress: TimeInterval = 1.5
        static let congratulationSpecial: TimeInterval = 0.3
        static let congratulationDefault: TimeInterval = 0.5
        static let congratulationScaling: TimeInterval = 0.25
        static let hiding: TimeInterval = 0.2
    }
    
    private var label: UILabel!
    private var frontView: UIView!
    private var frontLabel: UILabel!
    private var congratulationLabel: UILabel!
    private var congratulationView: UIView!
    private var frontViewShadowLayer: CAGradientLayer!
    
    var text: String = "" {
        didSet {
            label.text = text
            frontLabel.text = text
        }
    }
    
    var progress: Float = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func setProgress(value: Float, animated: Bool, completion: (() -> ())? = nil) {
        if value < progress {
            // Animate from value to 1.0
            setProgress(value: 1.0, animated: true) {
                // Manually set progress = 0
                self.progress = 0.0
                self.frontView.frame.size.width = 0.0
                self.frontViewShadowLayer.frame.size.width = 0.0
                // Animate from 0.0 to value
                self.setProgress(value: value, animated: true)
            }
            return
        }
        
        progress = value
        if animated {
            self.frontViewShadowLayer.frame.size.width = self.bounds.width * CGFloat(value)
            UIView.animate(withDuration: AnimationDuration.progress, animations: {
                self.frontView.frame.size.width = self.bounds.width * CGFloat(value)
            }, completion: { _ in
                self.frontViewShadowLayer.frame.size.width = self.bounds.width * CGFloat(value)
                completion?()
            })
        } else {
            frontView.frame.size.width = bounds.width * CGFloat(value)
            frontViewShadowLayer.frame.size.width = bounds.width * CGFloat(value)
            completion?()
        }
    }
    
    func showCongratulation(text: String, duration: TimeInterval, isSpecial: Bool = false, completion: (() -> ())? = nil) {
        congratulationLabel.text = text
        UIView.transition(with: congratulationView, duration: isSpecial ? AnimationDuration.congratulationSpecial : AnimationDuration.congratulationDefault, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
            self.congratulationView.alpha = 1.0
            
            if isSpecial {
                let animation = CABasicAnimation(keyPath: "transform.scale")
                animation.duration = AnimationDuration.congratulationScaling
                animation.repeatCount = 2
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.autoreverses = true
                animation.fromValue = NSNumber(value: 1.0)
                animation.toValue = NSNumber(value: 0.9)
                self.congratulationLabel.layer.add(animation, forKey: "transform.scale")
            }
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: {
                UIView.transition(with: self.congratulationView, duration: isSpecial ? AnimationDuration.congratulationSpecial : AnimationDuration.congratulationDefault, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
                    self.congratulationView.alpha = 0.0
                    completion?()
                })
            })
        })
    }
    
    func hideCongratulation(force: Bool, completion: (() -> ())? = nil) {
        if force {
            self.congratulationView.alpha = 0.0
            completion?()
        } else {
            UIView.transition(with: congratulationView, duration: AnimationDuration.hiding, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
                self.congratulationView.alpha = 0.0
                completion?()
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    fileprivate func initView() {
        // Font
        if #available(iOS 8.2, *) {
            labelFont = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
        }
        
        // Make bg with light color (back)
        self.backgroundColor = mainColor?.withAlphaComponent(0.1)
        
        // Make main label (back)
        label = UILabel(frame: self.bounds)
        label.font = labelFont
        label.textAlignment = .center
        label.textColor = backLabelColor
        self.addSubview(label)
        
        // Make progress view (front)
        var frontFrame = self.bounds
        frontFrame.size.width = 0
        frontView = UIView(frame: frontFrame)
        frontView.backgroundColor = mainColor
        
        // Make main label (front)
        frontLabel = UILabel(frame: self.bounds)
        frontLabel.font = labelFont
        frontLabel.textAlignment = label.textAlignment
        frontLabel.textColor = frontLabelColor
        frontView.addSubview(frontLabel)
        frontView.clipsToBounds = true
        
        // Make front gradient
        frontViewShadowLayer = CAGradientLayer()
        frontViewShadowLayer.cornerRadius = self.layer.cornerRadius
        frontViewShadowLayer.frame = frontView.bounds
        frontViewShadowLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor
        ]
        frontView.layer.addSublayer(frontViewShadowLayer)
        self.addSubview(frontView)
        
        // Congratulation view
        congratulationView = UIView(frame: self.bounds)
        congratulationView.alpha = 0.0
        congratulationView.backgroundColor = congratulationColor
        congratulationLabel = UILabel(frame: self.bounds)
        congratulationLabel.font = labelFont
        congratulationLabel.textAlignment = label.textAlignment
        congratulationLabel.textColor = congratulationLabelColor
        congratulationView.addSubview(congratulationLabel)
        
        let congratsShadowLayer = CAGradientLayer()
        congratsShadowLayer.cornerRadius = self.layer.cornerRadius
        congratsShadowLayer.frame = congratulationView.bounds
        congratsShadowLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor
        ]
        congratulationView.layer.addSublayer(congratsShadowLayer)
        self.addSubview(congratulationView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Recenter (maybe constraints?)
        label.center.x = center.x
        frontLabel.center.x = center.x
        congratulationLabel.center.x = center.x
        
        // Recalculate progress
        frontView.frame.size.width = bounds.width * CGFloat(progress)
        frontViewShadowLayer.frame.size.width = bounds.width * CGFloat(progress)
    }
}
