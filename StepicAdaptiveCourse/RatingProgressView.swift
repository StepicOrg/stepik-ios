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
        if animated {
            if value > progress {
                self.frontViewShadowLayer.frame.size.width = self.bounds.width * CGFloat(value)
            }
            UIView.animate(withDuration: 2.0, animations: {
                self.frontView.frame.size.width = self.bounds.width * CGFloat(value)
            }, completion: { _ in
                if value > self.progress {
                    self.frontViewShadowLayer.frame.size.width = self.bounds.width * CGFloat(value)
                }
                self.progress = value
                completion?()
            })
        } else {
            progress = value
            frontView.frame.size.width = bounds.width * CGFloat(value)
            frontViewShadowLayer.frame.size.width = bounds.width * CGFloat(value)
            completion?()
        }
    }
    
    func showCongratulation(text: String, duration: TimeInterval, isSpecial: Bool = false, completion: (() -> ())? = nil) {
        congratulationLabel.text = text
        UIView.transition(with: congratulationView, duration: isSpecial ? 0.3 : 0.5, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
            self.congratulationView.alpha = 1.0
            
            if isSpecial {
                let animation = CABasicAnimation(keyPath: "transform.scale")
                animation.duration = 0.25
                animation.repeatCount = 2
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.autoreverses = true
                animation.fromValue = NSNumber(value: 1.0)
                animation.toValue = NSNumber(value: 0.9)
                self.congratulationLabel.layer.add(animation, forKey: "transform.scale")
            }
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: {
                UIView.transition(with: self.congratulationView, duration: isSpecial ? 0.3 : 0.5, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
                    self.congratulationView.alpha = 0.0
                    completion?()
                })
            })
        })
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
        
        frontView.frame.size.width = bounds.width * CGFloat(progress)
        frontViewShadowLayer.frame.size.width = bounds.width * CGFloat(progress)
    }
}
