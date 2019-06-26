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

extension SegmentedProgressView {
    struct Appearance {
        var spacing: CGFloat = 5
        var barColor = UIColor.white.withAlphaComponent(0.5)
        var progressColor = UIColor.white.withAlphaComponent(1)
    }
}

class SegmentedProgressView: UIView {

    var appearance = Appearance()
    var isAutoPlayEnabled = false
    var segmentsCount = 0 {
        didSet {
            addProgresses()
        }
    }

    private var progressesStackView = UIStackView(arrangedSubviews: [])

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
        backgroundColor = .clear
        progressesStackView.alignment = .fill
        progressesStackView.distribution = .fillEqually
        progressesStackView.spacing = appearance.spacing

        progressesStackView.snp.makeConstraints {
            make in
            make.edges.equalToSuperview().priority(ConstraintPriority.required)
        }
    }

    private func addProgresses() {
        progressViews.forEach { progressesStackView.removeArrangedSubview($0) }
        progressViews = []
        for _ in 0 ..< segmentsCount {
            let progressView = SegmentAnimatedProgressView(barColor: appearance.barColor, progressColor: appearance.progressColor)

            progressesStackView.addArrangedSubview(progressView)
            progressViews += [progressView]
        }
        progressesStackView.setNeedsLayout()
        progressesStackView.layoutIfNeeded()
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
            set(segment: id, completed: id < segment)
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

    func resume(segment: Int) {
        guard isInBounds(index: segment) else {
            return
        }
        progressViews[segment].isPaused = false
    }
}

private class SegmentAnimatedProgressView: UIView {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    private var topWidthConstraint: Constraint?

    private var didLayout = false

    var isPaused = false {
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
        topSegmentView.snp.makeConstraints { make in
            topWidthConstraint = make.width.equalTo(self.snp.width).multipliedBy(CGFloat.leastNormalMagnitude).constraint

        }
        topWidthConstraint?.activate()

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
        topWidthConstraint?.deactivate()
        topSegmentView.snp.makeConstraints { make in
            topWidthConstraint = make.width.equalTo(self.snp.width).multipliedBy(1).constraint
        }
        topWidthConstraint?.activate()
        self.setNeedsLayout()
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
        isPaused = false
        topSegmentView.layer.removeAllAnimations()
        topWidthConstraint?.deactivate()
        topSegmentView.snp.makeConstraints { make in
            topWidthConstraint = make.width.equalTo(self.snp.width).multipliedBy(progress == 0 ? CGFloat.leastNormalMagnitude : progress).constraint
        }
        topWidthConstraint?.activate()
        self.updateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
