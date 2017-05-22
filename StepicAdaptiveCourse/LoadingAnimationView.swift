//
//  LoadingAnimationView.swift
//  CardsDemo
//
//  Created by Vladislav Kiryukhin on 06.04.17.
//  Copyright © 2017 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

class LoadingAnimationView: UIView {
    private let width: [CGFloat] = [1.0, 0.6, 0.9, 0.5]
    
    var segments: [UIView] = []
    
    override func layoutSubviews() {
        redrawSegments()
    }
    
    fileprivate func redrawSegments() {
        segments.forEach { segment in
            segment.removeFromSuperview()
        }
        segments.removeAll()
        
        let parentWidth = self.frame.width
        let parentHeight = self.frame.height
        
        let indent: CGFloat = (parentHeight / 10) * 1.9
        let barHeight: CGFloat = parentHeight / 10
        
        for row in 0..<4 {
            let currentWidth = CGFloat(parentWidth) * width[row]
            let offsetY = (barHeight + indent) * CGFloat(row)
            
            segments += [UIView(frame: CGRect(x: 0.0, y: offsetY, width: currentWidth * 0.5, height: barHeight)),
                         UIView(frame: CGRect(x: currentWidth * 0.5, y: offsetY, width: currentWidth * 0.5, height: barHeight))]
        }
        segments = segments.map { segment in
            segment.backgroundColor = UIColor.black
            self.addSubview(segment)
            return segment
        }
        
        for i in 0..<segments.count {
            let animation = CAKeyframeAnimation(keyPath: "backgroundColor")
            animation.values = [UIColor(red: 102 / 255.0, green: 204 / 255.0, blue: 102 / 255.0, alpha: 1.0).cgColor]
            animation.keyTimes = [1]
            animation.duration = 1.2
            animation.beginTime = 0 + 0.05 + Double(i) * 0.15
            
            let animationGroup = CAAnimationGroup()
            animationGroup.beginTime = 0
            animationGroup.duration = 1.25
            animationGroup.animations = [animation]
            animationGroup.repeatCount = HUGE
            segments[i].layer.add(animationGroup, forKey: "fillAnimation")
        }
    }
}
