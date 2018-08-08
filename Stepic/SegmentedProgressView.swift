//
//  SegmentedProgressView.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 02.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SegmentedProgressView: UIView {
    
    var spacing: CGFloat = 5
    var barColor: UIColor = UIColor.white.withAlphaComponent(0.3)
    var progressColor: UIColor = UIColor.white.withAlphaComponent(1)
    var isAutoPlayEnabled: Bool = false
    var segmentsCount: Int = 0 {
        didSet {
            addProgresses()
        }
    }

    private var progressesStackView: UIStackView = UIStackView(arrangedSubviews: [])
    
    var completion: (() -> Void)?
    
    private var progressViews: [SegmentAnimatedProgressView] = []
    
    private var didLayout = false
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressesStackView.layoutIfNeeded()
        progressViews.forEach { $0.layoutIfNeeded() }
    }
    
    private func setupView() {
        addSubview(progressesStackView)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        progressesStackView.alignment = .fill
        progressesStackView.distribution = .fillEqually
        progressesStackView.spacing = spacing
        
        progressesStackView.snp.makeConstraints {
            make in
            make.top.leading.bottom.trailing.equalToSuperview().priority(ConstraintPriority.required)
        }
    }
    
    private func addProgresses() {
        progressViews.forEach { progressesStackView.removeArrangedSubview($0) }
        progressViews = []
        for _ in 0 ..< segmentsCount {
            let progressView = SegmentAnimatedProgressView(barColor: barColor, progressColor: progressColor)
            
            progressesStackView.addArrangedSubview(progressView)
            progressViews += [progressView]
        }
        progressesStackView.layoutSubviews()
    }
    
    private func isInBounds(index: Int) -> Bool {
        return index >= 0 && index < segmentsCount
    }
    
    func animate(duration: TimeInterval, segment: Int) {
        guard isInBounds(index: segment) else {
            completion?()
            return
        }
        
        for id in 0 ..< segmentsCount {
            progressViews[id].set(progress: (id < segment ? 1 : 0))
        }
        progressViews[segment].animate(duration: duration, completion: completion)
    }
    
    func set(segment: Int, completed: Bool) {
        guard isInBounds(index: segment) else {
            return
        }
        progressViews[segment].set(progress: completed ? 1 : 0)
    }
    
    func pause(segment: Int) {
        guard isInBounds(index: segment) else {
            return
        }
        progressViews[segment].isPaused = true
    }
    
    func unpause(segment: Int) {
        guard isInBounds(index: segment) else {
            return
        }
        progressViews[segment].isPaused = false
    }
}

fileprivate class SegmentAnimatedProgressView: UIView {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    private var topWidthConstraint: NSLayoutConstraint?
    
    private var didLayout: Bool = false

    var isPaused: Bool = false {
        didSet {
            guard isPaused != oldValue else {
                return
            }
            if isPaused {
                let pausedTime = topSegmentView.layer.convertTime(CACurrentMediaTime(), from: nil)
                topSegmentView.layer.speed = 0.0
                topSegmentView.layer.timeOffset = pausedTime
            } else {
                let pausedTime = topSegmentView.layer.timeOffset
                topSegmentView.layer.speed = 1.0
                topSegmentView.layer.timeOffset = 0.0
                topSegmentView.layer.beginTime = 0.0
                let timeSincePause = topSegmentView.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                topSegmentView.layer.beginTime = timeSincePause
            }
        }
    }
    
    private func alignToSelf(view: UIView) {
        view.snp.makeConstraints { make in
            make.bottom.leading.top.equalToSuperview()
        }
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(bottomSegmentView)
        addSubview(topSegmentView)
        
        alignToSelf(view: topSegmentView)
        topWidthConstraint = topSegmentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0)
        topWidthConstraint?.isActive = true
        
        alignToSelf(view: bottomSegmentView)
        bottomSegmentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bottomSegmentView.layer.cornerRadius = frame.height / 2
        topSegmentView.layer.cornerRadius = frame.height / 2

        isPaused = false
        topSegmentView.layoutIfNeeded()
        bottomSegmentView.layoutIfNeeded()
    }
    
    init(barColor: UIColor, progressColor: UIColor) {
        bottomSegmentView.backgroundColor = barColor
        topSegmentView.backgroundColor = progressColor
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    func animate(duration: TimeInterval, completion: (() -> Void)?) {
        isPaused = false
        topWidthConstraint?.isActive = false
        topWidthConstraint = topSegmentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
        topWidthConstraint?.isActive = true
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: .curveLinear,
        animations: {
            self.layoutIfNeeded()
        }, completion: { [weak self] finished in
            if !finished {
                return
            }
            self?.isPaused = true
            completion?()
        })
    }
    
    func set(progress: CGFloat) {
        topSegmentView.layer.removeAllAnimations()
        topWidthConstraint?.isActive = false
        topWidthConstraint = topSegmentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: progress)
        topWidthConstraint?.isActive = true
        self.updateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
