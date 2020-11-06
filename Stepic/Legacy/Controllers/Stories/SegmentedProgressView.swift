//
//  SegmentedProgressView.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 02.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import SnapKit
import UIKit

extension SegmentedProgressView {
    struct Appearance {
        let spacing: CGFloat = 5
        let barColor = UIColor.white.withAlphaComponent(0.5)
        let progressColor = UIColor.white.withAlphaComponent(1)
    }
}

final class SegmentedProgressView: UIView {
    let appearance = Appearance()

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
        self.setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.progressesStackView.layoutIfNeeded()
        self.progressViews.forEach { $0.layoutIfNeeded() }
    }

    private func setupView() {
        self.addSubview(self.progressesStackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.progressesStackView.alignment = .fill
        self.progressesStackView.distribution = .fillEqually
        self.progressesStackView.spacing = self.appearance.spacing

        self.progressesStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().priority(.required)
        }
    }

    private func addProgresses() {
        self.progressViews.forEach { self.progressesStackView.removeArrangedSubview($0) }
        self.progressViews = []

        for _ in 0..<self.segmentsCount {
            let progressView = SegmentAnimatedProgressView(
                barColor: self.appearance.barColor,
                progressColor: self.appearance.progressColor
            )

            self.progressesStackView.addArrangedSubview(progressView)
            self.progressViews += [progressView]
        }

        self.progressesStackView.setNeedsLayout()
        self.progressesStackView.layoutIfNeeded()
    }

    private func isInBounds(index: Int) -> Bool { index >= 0 && index < self.segmentsCount }

    func animate(duration: TimeInterval, segment: Int) {
        guard self.isInBounds(index: segment) else {
            self.completion?()
            return
        }

        for id in 0..<self.segmentsCount {
            self.set(segment: id, completed: id < segment)
        }

        self.progressViews[segment].animate(duration: duration, completion: self.completion)
    }

    func set(segment: Int, completed: Bool) {
        guard self.isInBounds(index: segment) else {
            return
        }

        self.progressViews[segment].set(progress: completed ? 1 : 0)
    }

    func pause(segment: Int) {
        guard self.isInBounds(index: segment) else {
            return
        }

        self.progressViews[segment].isPaused = true
    }

    func resume(segment: Int) {
        guard self.isInBounds(index: segment) else {
            return
        }

        self.progressViews[segment].isPaused = false
    }
}

private class SegmentAnimatedProgressView: UIView {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    private var topWidthConstraint: Constraint?

    private var didLayout = false
    private var didFinishAnimations: Bool?

    private var duration: TimeInterval?
    private var progress: Double?
    private var completion: (() -> Void)?

    private var progressTimerRunCount: Double = 0
    private let progressTimerTimeInterval: TimeInterval = 0.1
    private weak var progressTimer: Timer?

    var isPaused = false {
        didSet {
            guard self.isPaused != oldValue else {
                return
            }

            if self.isPaused {
                let pausedTime = self.topSegmentView.layer.convertTime(CACurrentMediaTime(), from: nil)
                self.topSegmentView.layer.speed = 0.0
                self.topSegmentView.layer.timeOffset = pausedTime

                self.progressTimer?.invalidate()
            } else {
                let pausedTime = self.topSegmentView.layer.timeOffset
                self.topSegmentView.layer.speed = 1.0
                self.topSegmentView.layer.timeOffset = 0.0
                self.topSegmentView.layer.beginTime = 0.0
                let timeSincePause = self.topSegmentView.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                self.topSegmentView.layer.beginTime = timeSincePause

                let shouldRestoreAnimation = self.didFinishAnimations == false
                    && (self.progress != nil && self.progress! < 1)
                    && (self.topSegmentView.layer.animationKeys()?.isEmpty ?? true)

                if shouldRestoreAnimation {
                    self.restoreAnimationFromCurrentPosition()
                } else if let duration = self.duration {
                    self.scheduleTimer(duration: duration)
                }
            }
        }
    }

    init(barColor: UIColor, progressColor: UIColor) {
        self.bottomSegmentView.backgroundColor = barColor
        self.topSegmentView.backgroundColor = progressColor
        super.init(frame: CGRect.zero)
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public API

    func set(progress: CGFloat) {
        self.isPaused = false
        self.didFinishAnimations = nil
        self.duration = nil
        self.progress = nil
        self.completion = nil
        self.progressTimerRunCount = 0
        self.progressTimer?.invalidate()

        self.topSegmentView.layer.removeAllAnimations()
        self.topWidthConstraint?.deactivate()
        self.topSegmentView.snp.makeConstraints { make in
            self.topWidthConstraint = make.width
                .equalTo(self.snp.width)
                .multipliedBy(progress == 0 ? CGFloat.leastNormalMagnitude : progress)
                .constraint
        }
        self.topWidthConstraint?.activate()

        self.updateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func animate(duration: TimeInterval, completion: (() -> Void)?) {
        self.duration = duration
        self.completion = completion

        self.startAnimation(duration: duration, beginFromCurrentPosition: false, completion: completion)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.bottomSegmentView.layer.cornerRadius = self.frame.height / 2
        self.topSegmentView.layer.cornerRadius = self.frame.height / 2

        self.isPaused = false
        self.topSegmentView.layoutIfNeeded()
        self.bottomSegmentView.layoutIfNeeded()
    }

    // MARK: Private API

    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.bottomSegmentView)
        self.addSubview(self.topSegmentView)

        self.alignToSelf(view: self.topSegmentView)
        self.topSegmentView.snp.makeConstraints { make in
            self.topWidthConstraint = make.width
                .equalTo(self.snp.width)
                .multipliedBy(CGFloat.leastNormalMagnitude)
                .constraint
        }
        self.topWidthConstraint?.activate()

        self.alignToSelf(view: self.bottomSegmentView)
        self.bottomSegmentView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
    }

    private func alignToSelf(view: UIView) {
        view.snp.makeConstraints { make in
            make.bottom.leading.top.equalToSuperview()
        }
    }

    private func startAnimation(
        duration: TimeInterval,
        beginFromCurrentPosition: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        self.isPaused = false
        self.didFinishAnimations = nil

        var animationDuration = duration

        if beginFromCurrentPosition,
           let progress = self.progress {
            animationDuration = duration - (duration * progress)
            let currentWidth = self.bounds.width * CGFloat(progress)

            self.topWidthConstraint?.deactivate()
            self.topSegmentView.snp.makeConstraints { make in
                self.topWidthConstraint = make.width.equalTo(currentWidth).constraint
            }
            self.topWidthConstraint?.activate()

            self.updateConstraints()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

        self.topWidthConstraint?.deactivate()
        self.topSegmentView.snp.makeConstraints { make in
            self.topWidthConstraint = make.width.equalTo(self.snp.width).multipliedBy(1).constraint
        }
        self.topWidthConstraint?.activate()

        self.setNeedsLayout()

        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                self.layoutIfNeeded()
            },
            completion: { [weak self] finished in
                guard let strongSelf = self else {
                    return
                }

                if !finished {
                    strongSelf.didFinishAnimations = false
                    return
                }

                strongSelf.didFinishAnimations = true
                strongSelf.isPaused = true

                completion?()
            }
        )

        self.scheduleTimer(duration: duration)
    }

    private func restoreAnimationFromCurrentPosition() {
        guard let duration = self.duration,
              let completion = self.completion else {
            return
        }

        self.startAnimation(duration: duration, beginFromCurrentPosition: true, completion: completion)
    }

    private func scheduleTimer(duration: Double) {
        self.progressTimer?.invalidate()

        let newTimer = Timer(
            timeInterval: self.progressTimerTimeInterval,
            repeats: true,
            block: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.progressTimerRunCount += 1
                let progress = min(
                    1.0,
                    (strongSelf.progressTimerTimeInterval * strongSelf.progressTimerRunCount) / duration
                )

                if progress >= 1.0 {
                    strongSelf.progressTimer?.invalidate()
                }

                strongSelf.progress = progress
            }
        )
        self.progressTimer = newTimer

        RunLoop.current.add(newTimer, forMode: .common)
    }
}
