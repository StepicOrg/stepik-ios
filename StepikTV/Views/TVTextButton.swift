//
//  StandardButton.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class TVTextButton: UIButton, FocusAnimatable {

    func changeToDefault() {
        let font = UIFont.systemFont(ofSize: 38, weight: UIFontWeightMedium)
        let color = UIColor.clear

        self.transform = CGAffineTransform.identity
        self.layer.shadowOpacity = 0.0
        self.backgroundColor = color
        self.titleLabel?.font = font
    }

    func changeToFocused() {
        let font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightSemibold)
        let color = UIColor(red:0.50, green:0.79, blue:0.45, alpha:1.00)
        let scale = CGFloat(1.09)

        self.transform = CGAffineTransform(scaleX: scale, y: scale)
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.3
        self.backgroundColor = color
        self.titleLabel?.font = font
    }

    func changeToHighlighted() {
        self.transform = CGAffineTransform.identity
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.15
    }

    var defaultStateTitleColor: UIColor { return UIColor.black.withAlphaComponent(0.2) }
    var focusStateTitleColor: UIColor { return UIColor.white }

    private func initStyle() {
        self.layer.cornerRadius = 6

        setTitleColor(defaultStateTitleColor, for: .normal)
        setTitleColor(focusStateTitleColor, for: .focused)
        setTitleColor(focusStateTitleColor, for: .highlighted)

        self.contentHorizontalAlignment = .left
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 20.0, 0, 20.0)
        self.titleEdgeInsets = UIEdgeInsets.zero
        self.imageEdgeInsets = UIEdgeInsets.zero
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initStyle()
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.updateFocus(in: context, with: coordinator)
    }
}
