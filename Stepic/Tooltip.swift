//
//  Tooltip.swift
//  Stepic
//
//  Created by Ostrenkiy on 19.01.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import EasyTipView

protocol Tooltip {
    init(text: String, shouldDismissAfterTime: Bool, color: TooltipColor)
    func show(direction: TooltipDirection, in inView: UIView?, from fromView: UIView)
    func show(direction: TooltipDirection, in inView: UIView?, from fromItem: UIBarButtonItem)
    func dismiss()
}

enum TooltipColor {
    case light, dark

    var textColor: UIColor {
        switch self {
        case .light:
            return UIColor.mainDark
        case .dark:
            return UIColor.mainLight
        }
    }

    var borderColor: UIColor {
        switch self {
        case .light:
            return UIColor.mainDark
        case .dark:
            return UIColor.mainLight
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .light:
            return UIColor.mainLight
        case .dark:
            return UIColor.mainDark
        }
    }
}

class EasyTipTooltip: Tooltip {
    private var easyTip: EasyTipView = EasyTipView(text: "")
    private var preferences: EasyTipView.Preferences
    let dismissesAfter: TimeInterval = 5.0

    var text: String
    var shouldDismissAfterTime: Bool

    private func easyTipDirectionFromTooltipDirection(direction: TooltipDirection) -> EasyTipView.ArrowPosition {
        switch direction {
        case .up:
            return EasyTipView.ArrowPosition.top
        case .left:
            return EasyTipView.ArrowPosition.left
        case .right:
            return EasyTipView.ArrowPosition.right
        case .down:
            return EasyTipView.ArrowPosition.bottom
        }
    }

    required init(text: String, shouldDismissAfterTime: Bool, color: TooltipColor) {
        self.text = text
        self.shouldDismissAfterTime = shouldDismissAfterTime
        preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont.systemFont(ofSize: 13)
        preferences.drawing.foregroundColor = color.textColor
        preferences.drawing.backgroundColor = color.backgroundColor
        preferences.drawing.borderWidth = 1.0
        preferences.drawing.borderColor = color.borderColor
    }

    private func setupTooltip(direction: TooltipDirection) {
        preferences.drawing.arrowPosition = easyTipDirectionFromTooltipDirection(direction: direction)
        easyTip = EasyTipView(text: text, preferences: preferences, delegate: nil)
    }

    private func setupDisappear() {
        guard shouldDismissAfterTime else {
            return
        }
        delay(dismissesAfter) {
            [weak self] in
            self?.dismiss()
        }
    }

    func show(direction: TooltipDirection, in inView: UIView?, from fromView: UIView) {
        setupTooltip(direction: direction)
        easyTip.show(forView: fromView, withinSuperview: inView)
        setupDisappear()
    }

    func show(direction: TooltipDirection, in inView: UIView?, from fromItem: UIBarButtonItem) {
        setupTooltip(direction: direction)
        easyTip.show(forItem: fromItem, withinSuperView: inView)
        setupDisappear()
    }

    func dismiss() {
        easyTip.dismiss()
    }
}

enum TooltipDirection {
    case left, up, right, down
}
