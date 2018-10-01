//
//  SkeletonView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.06.2018.
//  Copyright © 2018 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

class SkeletonView: UIView {
    private static let maxSubviewDepth = 3

    private var cachedViews = [UIView]()
    private var shouldRebuildCache = true

    private var placeholderView: UIView? {
        didSet {
            rebuild(cleanCache: true)
        }
    }

    private var gradientLayer: CAGradientLayer?

    convenience init(placeholderView: UIView) {
        self.init()

        self.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false

        // For debug
        placeholderView.accessibilityIdentifier = "placeholderView"
        self.accessibilityIdentifier = "skeletonView"

        // We should add and hide placeholder view to get new layout in layoutSubviews()
        addSubview(placeholderView)
        placeholderView.alpha = 0.0
        placeholderView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        placeholderView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        placeholderView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        placeholderView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        self.placeholderView = placeholderView

        addGradient()
    }

    func show(in view: UIView) {
        if self.superview != nil && self.superview != view {
            self.removeFromSuperview()
        }

        self.tag = -1
        self.backgroundColor = .clear
        view.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    func hide() {
        self.removeFromSuperview()
    }

    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        // FIXME: extract colors
        gradientLayer.colors = [
            UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1.0).cgColor,
            UIColor(red: 0.907, green: 0.907, blue: 0.907, alpha: 1.0).cgColor,
            UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1.0).cgColor
        ]

        self.layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
    }

    private func rebuild(cleanCache: Bool) {
        guard let view = placeholderView else {
            return
        }

        if cleanCache || shouldRebuildCache {
            cachedViews.removeAll()
            cachedViews = traverseSubviews(view: view, maxDepth: SkeletonView.maxSubviewDepth)
            shouldRebuildCache = false
        }

        let mask = buildMaskLayer(with: cachedViews)
        gradientLayer?.mask = mask
    }

    private func convertFrame(for view: UIView) -> CGRect? {
        guard let mainSuperview = self.superview,
              let superview = view.superview else {
            return nil
        }

        return superview.convert(view.frame, to: mainSuperview)
    }

    private func buildMaskLayer(with views: [UIView]) -> CAShapeLayer {
        let mutablePath = CGMutablePath()
        for view in views {
            if let convertedFrame = convertFrame(for: view) {
                // Strange Apple's assertions in CoreGraphics:
                //     (corner_width >= 0 && 2 * corner_width <= CGRectGetWidth(rect))
                //     (corner_height >= 0 && 2 * corner_width <= CGRectGetHeight(rect))
                // Appears when condition is true, some workaround to fix them
                let cornerWidth = max(0.0, min(view.layer.cornerRadius, convertedFrame.width * 0.5 - 1e-3))
                let cornerHeight = max(0.0, min(view.layer.cornerRadius, convertedFrame.height * 0.5 - 1e-3))
                mutablePath.addRoundedRect(in: convertedFrame, cornerWidth: cornerWidth, cornerHeight: cornerHeight)
            }
        }
        mutablePath.closeSubpath()

        let maskLayer = CAShapeLayer()
        maskLayer.path = mutablePath

        return maskLayer
    }

    private func traverseSubviews(view: UIView, maxDepth: Int) -> [UIView] {
        func traverse(view: UIView, depth: Int) -> [UIView] {
            if view.tag == -1 {
                return []
            }

            if depth == maxDepth || view.subviews.count == 0 {
                return [view]
            }

            var views = [UIView]()
            for subview in view.subviews {
                views.append(contentsOf: traverse(view: subview, depth: depth + 1))
            }
            return views
        }

        return traverse(view: view, depth: 0)
    }

    private func animate() {
        let animationKey = "skeletonView"

        self.gradientLayer?.removeAnimation(forKey: animationKey)
        self.gradientLayer?.add(SkeletonViewAnimation.sliding.animation, forKey: animationKey)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.setNeedsLayout()

        rebuild(cleanCache: false)
        gradientLayer?.frame = self.bounds
        animate()
    }
}
