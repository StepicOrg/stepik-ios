//
//  StandardButton.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class StandardButton: UIButton {

    var changeToDefault: () -> Void {
        return {
            let font = UIFont.systemFont(ofSize: 38, weight: UIFontWeightMedium)
            let color = UIColor.clear

            self.transform = CGAffineTransform.identity
            self.layer.shadowOpacity = 0.0
            self.backgroundColor = color
            self.titleLabel?.font = font
        }
    }

    var changeToFocused: () -> Void {
        return {
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
    }

    var changeToHighlighted: () -> Void {
        return {
            self.transform = CGAffineTransform.identity
            self.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.layer.shadowOpacity = 0.15
        }
    }

    var defaultStateTitleColor: UIColor { get { return UIColor.black.withAlphaComponent(0.2) } }

    var focusStateTitleColor: UIColor { get { return UIColor.white } }

    private func initStyle() {
        self.layer.cornerRadius = 6
        setTitleColor(defaultStateTitleColor, for: .normal)
        setTitleColor(focusStateTitleColor, for: .focused)
        setTitleColor(focusStateTitleColor, for: .highlighted)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Events to look for a Highlighted state

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: 0.1, animations: self.changeToHighlighted )
        super.pressesBegan(presses, with: event)
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: 0.1, animations: self.changeToFocused )
        super.pressesCancelled(presses, with: event)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: 0.1, animations: self.changeToFocused )
        super.pressesEnded(presses, with: event)
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        // Mimik system focus/unfocus animation besides backgroundColor and title font

        if context.nextFocusedView == self {

            let animation: ((UIFocusAnimationContext) -> Void) = {
                let duration = $0.duration
                UIView.animate(withDuration: duration, animations: self.changeToFocused)
            }
            coordinator.addCoordinatedFocusingAnimations(animation, completion: nil)

        } else if context.previouslyFocusedView == self {

            let animation: ((UIFocusAnimationContext) -> Void) = {
                let duration = $0.duration
                UIView.animate(withDuration: duration, animations: self.changeToDefault)
            }
            coordinator.addCoordinatedUnfocusingAnimations( animation, completion: nil)
        }
    }
}
